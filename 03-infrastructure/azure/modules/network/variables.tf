variable "resource_group_name" {
  description = "Name of the resource group (aangemaakt door infra team)"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing VNet (aangemaakt door infra team via hub-spoke)"
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

variable "subnets" {
  description = "Map of subnet configurations. Address prefixes komen uit IPAM."
  type = map(object({
    address_prefixes = list(string)
  }))
}
