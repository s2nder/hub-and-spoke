locals {
  hub-location = "eastus"
  prefix-hub   = "hub"
  vm-size-hub  = "Standard_DS1_v2"
}

resource "azurerm_resource_group" "hub-network-rg" {
  name     = "${local.prefix-hub}-rg"
  location = local.hub-location
}

resource "azurerm_virtual_network" "hub-network" {
  name                = "${local.prefix-hub}-vnet"
  location            = azurerm_resource_group.hub-network-rg.location
  resource_group_name = azurerm_resource_group.hub-network-rg.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "hub-subnet" {
  name                 = "${local.prefix-hub}-subnet"
  resource_group_name  = azurerm_resource_group.hub-network-rg.name
  virtual_network_name = azurerm_virtual_network.hub-network.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_network_interface" "hub-nic" {
  name                = "${local.prefix-hub}-nic"
  location            = azurerm_resource_group.hub-network-rg.location
  resource_group_name = azurerm_resource_group.hub-network-rg.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "hub-vm" {
  name                = "${local.prefix-hub}-vm"
  resource_group_name = azurerm_resource_group.hub-network-rg.name
  location            = azurerm_resource_group.hub-network-rg.location
  size                = local.vm-size-hub
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
