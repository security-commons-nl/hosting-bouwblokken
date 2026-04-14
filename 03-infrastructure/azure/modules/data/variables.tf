variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, acc, prd)"
  type        = string
}

variable "location_short" {
  description = "Short location code (e.g., weu)"
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique name for the storage account"
  type        = string
}

variable "allowed_storage_ips" {
  description = "List of public IP addresses allowed to access the storage account (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
