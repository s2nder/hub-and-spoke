resource "azurerm_virtual_network" "hub-network" {
  name                = "hub-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "hub-subnet" {
  name                 = "hub-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub-network.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_network_interface" "hub-nic" {
  name                = "hub-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "hub-vm" {
  name                = "dev-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.hub-nic.id,
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
