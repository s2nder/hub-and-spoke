/*
resource "azurerm_virtual_network" "dev-network" {
  count = 3

  name                = "dev-network-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [ "10.${count.index}.0.0/16" ]
}

resource "azurerm_subnet" "subnet_vnet" {
  count = 3

  name                 = "default"
  virtual_network_name = azurerm_virtual_network.dev-network-[count.index].name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.${count.index}.0.0/24"]
}
*/

resource "azurerm_virtual_network" "dev-network" {
  name                = "dev-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "dev-subnet" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.dev-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "dev-nic" {
  name                = "dev-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "dev-vm" {
  name                = "dev-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.dev-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
