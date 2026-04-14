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

variable "retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 90
}

variable "key_vault_id" {
  description = "ID of the Key Vault to monitor"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account for diagnostics"
  type        = string
}

variable "subscription_id" {
  description = "Full subscription resource ID for policy assignments and budgets"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in EUR"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
