locals {
  location-vnet-1 = "eastus"
  name-vnet-1     = "vnet-1-spoke"
  vnet-1-ip-cidr  = ["10.1.0.0/16"]
  subnet-vnet-1-cidr = ["10.1.0.0/24"]
}

resource "azurerm_resource_group" "vnet-1-spoke" {
  name     = "${local.name-vnet-1}-rg"
  location = local.location-vnet-1
}

resource "azurerm_virtual_network" "vnet-1-spoke" {
  name                = "${local.name-vnet-1}-virtual-network"
  address_space       = local.vnet-1-ip-cidr
  location            = azurerm_resource_group.vnet-1-spoke.location
  resource_group_name = azurerm_resource_group.vnet-1-spoke.name
}

resource "azurerm_subnet" "vnet-1-spoke-sub" {
  name                 = "${local.name-vnet-1}-subnet"
  resource_group_name  = azurerm_resource_group.vnet-1-spoke.name
  virtual_network_name = azurerm_virtual_network.vnet-1-spoke.name
  address_prefixes     = local.subnet-vnet-1-cidr
}

resource "azurerm_network_interface" "vnet-1-spoke-nic" {
  name                = "${local.name-hub}-nic"
  location            = azurerm_resource_group.vnet-1-spoke.location
  resource_group_name = azurerm_resource_group.vnet-1-spoke.id

  ip_configuration {
    name                          = "${local.name-hub}-internal"
    subnet_id                     = azurerm_subnet.vnet-1-spoke-sub.id
    private_ip_address_allocation = "Dynamic"
  }
}