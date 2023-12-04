locals {
  hub-name = "hub"
  sku-hub  = "Standard"
}

# Azure Bastion/ Azure Firewall/ VPN gatewey

# Create VNET
resource "azurerm_virtual_network" "hub-vinet" {
  name                = "${local.hub-name}-virtual-network"
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
}

# Bastion subnet
resource "azurerm_subnet" "hub-bast-subnet" {
  name                 = "${local.hub-name}-bust-subnet"
  resource_group_name  = azurerm_resource_group.hub-and-spoke.name
  virtual_network_name = azurerm_virtual_network.hub-vinet.name
  address_prefixes     = ["192.168.1.224/27"]
}

# Firewall subnet
resource "azurerm_subnet" "hub-azfw-subnet" {
  name                 = "${local.hub-name}-azfw-subnet"
  resource_group_name  = azurerm_resource_group.hub-and-spoke.name
  virtual_network_name = azurerm_virtual_network.hub-vinet.name
  address_prefixes     = ["192.168.10.0/26"]
}

#### HUB #### SUB #### NET ####
resource "azurerm_subnet" "workload_subnet" {
  name                 = "subnet-workload"
  resource_group_name  = azurerm_resource_group.hub-and-spoke.name
  virtual_network_name = azurerm_virtual_network.hub-vinet.name
  address_prefixes     = ["192.168.5.0/24"]
}

resource "azurerm_subnet" "jump_subnet" {
  name                 = "subnet-jump"
  resource_group_name  = azurerm_resource_group.hub-and-spoke.name
  virtual_network_name = azurerm_virtual_network.hub-vinet.name
  address_prefixes     = ["192.168.6.0/24"]
}
###############################

# Virtual hub
resource "azurerm_virtual_wan" "hub-azfw_vwan" {
  name                           = "${local.hub-name}-vwan-azfw-securehub-eus"
  location                       = azurerm_resource_group.hub-and-spoke.location
  resource_group_name            = azurerm_resource_group.hub-and-spoke.name
  allow_branch_to_branch_traffic = true
  disable_vpn_encryption         = false
}

resource "azurerm_virtual_hub" "hub-azfw_vwan_hub" {
  name                = "${local.hub-name}-azfw-securehub-eus"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  virtual_wan_id      = azurerm_virtual_wan.hub-azfw_vwan.id
  address_prefix      = "192.168.2.0/24"
}

resource "azurerm_virtual_hub_route_table" "hub-vhub-rt" {
  name           = "${local.hub-name}-vhub-rt-azfw-securehub-eus"
  virtual_hub_id = azurerm_virtual_hub.hub-azfw_vwan_hub.id
  route {
    name              = "workload-SNToFirewall"
    destinations_type = "CIDR"
    destinations      = ["192.168.2.0/24"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.hub-fw.id
  }
  route {
    name              = "InternetToFirewall"
    destinations_type = "CIDR"
    destinations      = ["0.0.0.0/0"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.hub-fw.id
  }
  labels = ["VNet"]
}

resource "azurerm_virtual_hub_connection" "hub-azfw_vwan_hub_connection" {
  name                      = "${local.hub-name}-to-spoke"
  virtual_hub_id            = azurerm_virtual_hub.hub-azfw_vwan_hub.id
  remote_virtual_network_id = azurerm_virtual_network.hub-vinet.id
  internet_security_enabled = true
  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.hub-vhub-rt.id
    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub_route_table.hub-vhub-rt.id]
      labels          = ["VNet"]
    }
  }
}

# An IP Group is a top-level resource that allows you to define and
# group IP addresses, ranges, and subnets into a single object. IP Group
# is useful for managing IP addresses in Azure Firewall rules. You can
# either manually enter IP addresses or import them from a file.
resource "azurerm_ip_group" "workload_ip_group" {
  name                = "${local.hub-name}-workload-ip-group"
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  location            = azurerm_resource_group.hub-and-spoke.location
  cidrs               = ["192.168.20.0/24", "192.168.30.0/24"]
}

resource "azurerm_ip_group" "infra_ip_group" {
  name                = "${local.hub-name}-infra-ip-group"
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  location            = azurerm_resource_group.hub-and-spoke.location
  cidrs               = ["192.168.40.0/24", "192.168.50.0/24"]
}

# Hub Public IP
resource "azurerm_public_ip" "hub-pip" {
  name                = "${local.hub-name}-pip"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  allocation_method   = "Static"
  sku                 = local.sku-hub
}

# Bastion Host
resource "azurerm_bastion_host" "hub-bast-host" {
  name                = "${local.hub-name}-bastion-host"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub-bast-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-pip.id
  }
}

resource "azurerm_firewall_policy" "hub-azfw_policy" {
  name                     = "${local.hub-name}-azfw-policy"
  resource_group_name      = azurerm_resource_group.hub-and-spoke.name
  location                 = azurerm_resource_group.hub-and-spoke.location
  sku                      = local.sku-hub
  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "hub-net-policy-rule-collection-group" {
  name               = "${local.hub-name}-def-net-rule-collection-group"
  firewall_policy_id = azurerm_firewall_policy.hub-azfw_policy.id
  priority           = 300

  network_rule_collection {
    name     = "DefaultNetworkRuleCollection"
    action   = "Allow"
    priority = 300
    rule {
      name                  = "time-windows"
      protocols             = ["TCP", "UDP"]
      source_ip_groups      = [azurerm_ip_group.workload_ip_group.id, azurerm_ip_group.infra_ip_group.id]
      destination_ports     = ["3000-4000"]
      destination_addresses = ["192.168.100.1", "192.168.100.2"]
    }
  }

  application_rule_collection {
    name     = "DefaultApplicationRuleCollection"
    action   = "Allow"
    priority = 400
    rule {
      name = "AllowWindowsUpdate"

      description = "Allow Windows Update"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }

      source_ip_groups = [azurerm_ip_group.workload_ip_group.id, azurerm_ip_group.infra_ip_group.id]
    }

    rule {
      name        = "Global Rule"
      description = "Allow access to Microsoft.com"
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = ["*.microsoft.com"]
      terminate_tls     = false
      source_ip_groups  = [azurerm_ip_group.workload_ip_group.id, azurerm_ip_group.infra_ip_group.id]
    }
  }
}

resource "azurerm_firewall" "hub-fw" {
  name                = "${local.hub-name}-azfw"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  sku_name            = "AZFW_VNet"
  sku_tier            = local.sku-hub

  ip_configuration {
    name                 = "azfw-ipconfig"
    subnet_id            = azurerm_subnet.hub-azfw-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-pip.id
  }

  firewall_policy_id = azurerm_firewall_policy.hub-azfw_policy.id
}

#### Network #### Interface ####
resource "azurerm_network_interface" "hub-vm-workload-nic" {
  name                = "${local.hub-name}-nic-workload"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name

  ip_configuration {
    name                          = "ipconfig-workload"
    subnet_id                     = azurerm_subnet.workload_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "hub-vm-jump-nic" {
  name                = "${local.hub-name}-nic-jump"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name

  ip_configuration {
    name                          = "ipconfig-jump"
    subnet_id                     = azurerm_subnet.jump_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub-pip.id
  }
}

#### Network #### Security #### Group ####
resource "azurerm_network_security_group" "hub-vm-workload-nsg" {
  name                = "${local.hub-name}-nsg-workload"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
}

resource "azurerm_network_security_group" "hub-vm-jump-nsg" {
  name                = "${local.hub-name}-nsg-jump"
  location            = azurerm_resource_group.hub-and-spoke.location
  resource_group_name = azurerm_resource_group.hub-and-spoke.name
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}