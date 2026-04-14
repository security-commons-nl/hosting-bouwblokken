output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.network.subnet_ids
}

output "vm_private_ip" {
  description = "Private IP address of the app VM"
  value       = module.compute.vm_private_ip
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.data.key_vault_uri
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.data.storage_account_name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}
