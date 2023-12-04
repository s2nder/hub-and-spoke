resource "azurerm_virtual_network_peering" "vnet-1-spoke-to-hub-peer" {
  name                      = "${local.name-vnet-1}-to-hub-peer"
  resource_group_name       = azurerm_resource_group.vnet-1-spoke.name
  virtual_network_name      = azurerm_virtual_network.vnet-1-spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.vnet-1-spoke,
    azurerm_virtual_network.hub-vnet,
    #azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_virtual_network_peering" "hub-to-vnet-1-spoke-peer" {
  name                      = "${local.name-vnet-1}-to-hub-peer"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-1-spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network.vnet-1-spoke,
    #azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_virtual_network_peering" "vnet-2-spoke-to-hub-peer" {
  name                      = "${local.name-vnet-2}-to-hub-peer"
  resource_group_name       = azurerm_resource_group.vnet-2-spoke.name
  virtual_network_name      = azurerm_virtual_network.vnet-2-spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.vnet-2-spoke,
    azurerm_virtual_network.hub-vnet,
    #azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_virtual_network_peering" "hub-to-vnet-2-spoke-peer" {
  name                      = "${local.name-vnet-2}-to-hub-peer"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-2-spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network.vnet-2-spoke,
    #azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}