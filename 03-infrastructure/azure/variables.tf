variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Project name used in resource naming (e.g., 'myapp', 'sandbox')"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., 'dev', 'acc', 'prd')"
  type        = string
  default     = "dev"
}

variable "location_short" {
  description = "Short location code for resource naming (e.g., 'weu' for westeurope)"
  type        = string
  default     = "weu"
}

# --- Hub-spoke: bestaande resources van infra team ---

variable "resource_group_name" {
  description = "Naam van de bestaande resource group (aangemaakt door infra team)"
  type        = string
}

variable "vnet_name" {
  description = "Naam van de bestaande spoke VNet (aangemaakt door infra team, IP ranges uit IPAM)"
  type        = string
}

# --- Subnets binnen de spoke VNet ---

variable "subnets" {
  description = "Map van subnet configuraties. Address prefixes worden bepaald door het infra team (IPAM)."
  type = map(object({
    address_prefixes = list(string)
  }))
}

# --- Compute ---

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2ms"
}

variable "vm_admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureadmin"
}

variable "vm_ssh_public_key_path" {
  description = "Path to the SSH public key file for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# --- Data ---

variable "storage_account_name" {
  description = "Globally unique name for the storage account (max 24 chars, no hyphens)"
  type        = string
}

# --- Monitoring & Budget ---

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace data retention in days"
  type        = number
  default     = 90
}

variable "monthly_budget_amount" {
  description = "Monthly budget limit in EUR"
  type        = number
  default     = 150
}

variable "budget_start_date" {
  description = "Budget start date in YYYY-MM-01 format"
  type        = string
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alert notifications"
  type        = list(string)
}

# --- Tags ---

variable "tags" {
  description = "Extra tags (worden samengevoegd met tags van de resource group)"
  type        = map(string)
}
