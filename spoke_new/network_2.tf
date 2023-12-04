locals {
  location-vnet-2 = "eastus"
  name-vnet-2     = "vnet-2-spoke"
  vnet-2-ip-cidr  = ["10.2.0.0/16"]
  subnet-vnet-2-cidr = ["10.2.0.0/24"]
}

resource "azurerm_resource_group" "vnet-2-spoke" {
  name     = "${local.name-vnet-2}-rg"
  location = local.location-vnet-2
}

resource "azurerm_virtual_network" "vnet-2-spoke" {
  name                = "${local.name-vnet-2}-virtual-network"
  address_space       = local.vnet-2-ip-cidr
  location            = azurerm_resource_group.vnet-2-spoke.location
  resource_group_name = azurerm_resource_group.vnet-2-spoke.name
}

resource "azurerm_subnet" "vnet-2-spoke-sub" {
  name                 = "${local.name-vnet-2}-subnet"
  resource_group_name  = azurerm_resource_group.vnet-2-spoke.name
  virtual_network_name = azurerm_virtual_network.vnet-2-spoke.name
  address_prefixes     = local.subnet-vnet-2-cidr
}

resource "azurerm_network_interface" "vnet-2-spoke-nic" {
  name                = "${local.name-hub}-nic"
  location            = azurerm_resource_group.vnet-2-spoke.location
  resource_group_name = azurerm_resource_group.vnet-2-spoke.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet-2-spoke-sub.id
    private_ip_address_allocation = "Dynamic"
  }
}