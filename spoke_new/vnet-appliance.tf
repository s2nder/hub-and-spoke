locals {
    prefix-hub-nva         = "hub-nva"
    hub-nva-location       = "eastus"
    hub-nva-resource-group = "hub-nva-rg"
}

resource "azurerm_resource_group" "hub-nva-rg" {
    name     = "${local.prefix-hub-nva}-rg"
    location = local.hub-nva-location

    tags = {
    environment = local.prefix-hub-nva
    }
}