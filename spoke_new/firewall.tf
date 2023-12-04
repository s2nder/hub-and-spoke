locals {
  location-firewall = "eastus"
  name-firewall     = "firewall"
  sub-name          = "Firewall"
  sku               = ""
}

resource "azurerm_resource_group" "firewall" {
  name     = "${local.name-firewall}-rg"
  location = local.location-firewall
}

resource "azurerm_subnet" "firewall-sub" {
  name                 = "Azure${local.sub-name}Subnet"
  resource_group_name  = azurerm_resource_group.firewall.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "firewall-pip" {
  name                = "${local.name-firewall}-pip"
  location            = azurerm_resource_group.firewall.location
  resource_group_name = azurerm_resource_group.firewall.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_firewall" "firewall-az" {
  name                = "${local.name-firewall}-az"
  location            = azurerm_resource_group.firewall.location
  resource_group_name = azurerm_resource_group.firewall.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Basic"

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.firewall-sub.id
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
  }
}