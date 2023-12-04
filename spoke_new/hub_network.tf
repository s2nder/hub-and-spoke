locals {
  location-hub = "eastus"
  name-hub     = "hub"
  enviroment   = "hub-spoke"
  hub-ip-cidr  = ["10.0.0.0/16"]
}

resource "azurerm_resource_group" "hub" {
  name     = "${local.name-hub}-rg"
  location = local.location-hub
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${local.name-hub}-virtual-network"
  address_space       = local.hub-ip-cidr
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  tags = {
    enviroment = local.enviroment
  }
}

resource "azurerm_network_interface" "hub-nic" {
  name                = "${local.name-hub}-nic"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.id

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.firewall-sub.id
    private_ip_address_allocation = "Dynamic"
  }
}