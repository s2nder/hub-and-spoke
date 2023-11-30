resource "azurerm_virtual_network" "test-network" {
  name                = "test-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test-subnet" {
  name                 = "test-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.test-network.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_interface" "test-nic" {
  name                = "test-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "test-vm" {
  name                = "test-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.test-nic.id,
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
