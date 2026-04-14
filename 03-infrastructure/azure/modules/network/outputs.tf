output "vnet_id" {
  description = "ID of the virtual network"
  value       = data.azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = data.azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet keys to their IDs"
  value       = { for k, s in azurerm_subnet.subnets : k => s.id }
}
