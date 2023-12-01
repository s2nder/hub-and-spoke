locals {
  name     = "example-hub-and-spoke"
  location = "eastus"
}

resource "azurerm_resource_group" "hub-and-spoke" {
  name     = local.name
  location = local.location
}

################################################################
# Create three vnet
resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
}

resource "random_pet" "virtual_network_name" {
  prefix = "vnet-${random_string.prefix.result}"
}

resource "azurerm_virtual_network" "vnet" {
  count = 3

  name                = "${local.name}-${random_pet.virtual_network_name.id}-0${count.index}"
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  location            = azurerm_resource_group.hub-and-spoke.location
  address_space       = ["10.${count.index}.0.0/16"]
}

# Add a subnet to each virtual network

resource "azurerm_subnet" "subnet_vnet" {
  count = 3

  name                 = "${local.name}-0${count.index}"
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  resource_group_name  = azurerm_resource_group.hub-and-spoke.name
  address_prefixes     = ["10.${count.index}.0.0/24"]
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "hub-and-spoke-net-manager" {
  name                = "${local.name}-network-manager"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["Connectivity", "SecurityAdmin"]
  description    = "example network manager"
}

resource "azurerm_network_manager_network_group" "hub-and-spoke-mngr-net-group" {
  name               = "${local.name}-manager-network-group"
  network_manager_id = azurerm_network_manager.hub-and-spoke-net-manager.id
}

resource "random_pet" "network_group_policy_name" {
  prefix = "network-group-policy"
}

resource "azurerm_policy_definition" "network_group_policy" {
  name         = random_pet.network_group_policy_name.id
  policy_type  = "Custom"
  mode         = "Microsoft.Network.Data"
  display_name = "Policy Definition for Network Group"

  metadata = <<METADATA
    {
      "category": "Azure Virtual Network Manager"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
              "field": "type",
              "equals": "Microsoft.Network/virtualNetworks"
          },
          {
            "allOf": [
              {
              "field": "Name",
              "contains": "${random_pet.virtual_network_name.id}"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "addToNetworkGroup",
        "details": {
          "networkGroupId": "${azurerm_network_manager_network_group.hub-and-spoke-mngr-net-group.id}"
        }
      }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "azure_policy_assignment" {
  name                 = "${random_pet.network_group_policy_name.id}-policy-assignment"
  policy_definition_id = azurerm_policy_definition.network_group_policy.id
  subscription_id      = data.azurerm_subscription.current.id
}

resource "azurerm_network_manager_connectivity_configuration" "connectivity_config" {
  name                  = "${local.name}-connectivity-conf"
  network_manager_id    = azurerm_network_manager.hub-and-spoke-net-manager.id
  connectivity_topology = "HubAndSpoke"
  applies_to_group {
    group_connectivity = "DirectlyConnected"
    network_group_id   = azurerm_network_manager_network_group.hub-and-spoke-mngr-net-group.id
  }
  hub {
    #count = 3

    resource_id = azurerm_virtual_network.vnet[0].id
    #resource_id   = azurerm_virtual_network.vnet[count.index].id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
}