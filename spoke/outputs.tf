output "resource_group_name" {
  value = azurerm_resource_group.hub-and-spoke.name
}

output "virtual_network_names" {
  value = azurerm_virtual_network.vnet[*].name
}

output "firewall_name" {
  value = azurerm_firewall.hub-fw.name
}

output "bastion_name" {
  description = "Azure Bastion name."
  value       = azurerm_bastion_host.hub-bast-host.name
}

output "bastion_public_ip_name" {
  description = "Azure Bastion public IP resource name."
  value       = azurerm_public_ip.hub-pip.name
}

output "bastion_public_ip" {
  description = "Azure Bastion public IP."
  value       = azurerm_public_ip.hub-pip.ip_address
}