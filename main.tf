resource "azurerm_resource_group" "main" {
  name     = "main_network"
  location = "eastus"
}

resource "azurerm_virtual_network_peering" "dev-to-hub-peer" {
  name                         = "dev-to-hub"
  virtual_network_name         = azurerm_virtual_network.dev-network.name
  remote_virtual_network_id    = azurerm_virtual_network.hub-network.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub-to-dev-peer" {
  name                         = "hub-to-dev"
  virtual_network_name         = azurerm_virtual_network.hub-network.name
  remote_virtual_network_id    = azurerm_virtual_network.dev-network.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "dev-to-test-peer" {
  name                         = "dev-to-test"
  virtual_network_name         = azurerm_virtual_network.dev-network.name
  remote_virtual_network_id    = azurerm_virtual_network.test-network.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "test-to-dev-peer" {
  name                         = "test-to-dev"
  virtual_network_name         = azurerm_virtual_network.test-network.name
  remote_virtual_network_id    = azurerm_virtual_network.dev-network.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub-to-test-peer" {
  name                         = "hub-to-test"
  virtual_network_name         = azurerm_virtual_network.hub-network.name
  remote_virtual_network_id    = azurerm_virtual_network.test-network.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "test-to-hub-peer" {
  name                         = "test-to-hub"
  virtual_network_name         = azurerm_virtual_network.test-network.name
  remote_virtual_network_id    = azurerm_virtual_network.hub-network.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}