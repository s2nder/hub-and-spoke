locals {
  vm-location          = "eastus"
  vm-prefix            = "vm"
  vm-size              = "Standard_DS1_v2"
  count-vm-hub         = 0
  count-vm-vnet-1      = 0
  count-vm-vnet-2      = 0
  admin_username       = "adminuser"
  admin_password       = "P@$$w0rd1234!"
  storage_account_type = "Standard_LRS"
  image_sku            = "2016-Datacenter"
  image_version        = "latest"
}

resource "azurerm_windows_virtual_machine" "hub-vm" {
  count = local.count-vm-hub

  name                = "hub-${local.vm-prefix}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  size                = local.vm-size
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.hub-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.storage_account_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.image_sku
    version   = local.image_version
  }
}

resource "azurerm_windows_virtual_machine" "vnet-1-vm" {
  count = local.count-vm-vnet-1

  name                = "vnet-1-${local.vm-prefix}"
  resource_group_name = azurerm_resource_group.vnet-1-spoke.name
  location            = azurerm_resource_group.vnet-1-spoke.location
  size                = local.vm-size
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.vnet-1-spoke-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.storage_account_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.image_sku
    version   = local.image_version
  }
}

resource "azurerm_windows_virtual_machine" "vnet-2-vm" {
  count = local.count-vm-vnet-2

  name                = "vnet-2-${local.vm-prefix}"
  resource_group_name = azurerm_resource_group.vnet-1-spoke.name
  location            = azurerm_resource_group.vnet-1-spoke.location
  size                = local.vm-size
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.vnet-2-spoke-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.storage_account_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.image_sku
    version   = local.image_version
  }
}