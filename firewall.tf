resource "azurerm_subnet" "sub-firewall" {
  name                 = "sub-firewall"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub-network.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_public_ip" "pub-ip" {
  name                = "pub-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "az-firewall" {
  name                = "az-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.sub-firewall.id
    public_ip_address_id = azurerm_public_ip.pub-ip.id
  }
}