# Create on-prem VNET 
resource "azurerm_virtual_network" "onprem-vnet" {
    name                = "onprem-vnet"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    address_space       = ["192.168.0.0/16"]
}

# Create on-prime gateway subnet
resource "azurerm_subnet" "onprem-gateway-subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.onprem-vnet.name
    address_prefixes     = ["192.168.255.224/27"]
}

# Create on-prime managment subnet
resource "azurerm_subnet" "onprem-mgmt" {
    name                 = "mgmt"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.onprem-vnet.name
    address_prefixes     = ["192.168.1.128/25"]
}

# Create on-prem public IP
resource "azurerm_public_ip" "onprem-pip" {
    name                = "onprem-pip"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Dynamic"
}

# Create on-prem network interface
resource "azurerm_network_interface" "onprem-nic" {
    name                 = "on-prim-nic"
    location             = azurerm_resource_group.main.location
    resource_group_name  = azurerm_resource_group.main.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = "ip-on-prom-nic"
    subnet_id                     = azurerm_subnet.onprem-mgmt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.onprem-pip.id
    }
}

# Create on-prem network security group
resource "azurerm_network_security_group" "onprem-nsg" {
    name                = "on-prem-nsg"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Subnet network security group association betwin on-perm managment and network security group
resource "azurerm_subnet_network_security_group_association" "mgmt-nsg-association" {
    subnet_id                 = azurerm_subnet.onprem-mgmt.id
    network_security_group_id = azurerm_network_security_group.onprem-nsg.id
}

resource "azurerm_virtual_machine" "onprem-vm" {
    name                  = "ubuntu-vm"
    location              = azurerm_resource_group.main.location
    resource_group_name   = azurerm_resource_group.main.name
    network_interface_ids = [azurerm_network_interface.onprem-nic.id]
    vm_size               = "Standard_DS1_v2"

    storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
    }

    storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }

    os_profile {
    computer_name  = "ubuntu-vm"
    admin_username = "adminuser"
    admin_password = "P@$$w0rd1234!"
    }

    os_profile_linux_config {
    disable_password_authentication = false
    }
}

resource "azurerm_public_ip" "onprem-vpn-gateway-1-pip" {
    name                = "onprem-vpn-gateway-1-pip"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem-vpn-gateway" {
    name                = "onprem-vpn-gateway-1"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem-vpn-gateway-1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-gateway-subnet.id
    }
    depends_on = [azurerm_public_ip.onprem-vpn-gateway-1-pip]

}