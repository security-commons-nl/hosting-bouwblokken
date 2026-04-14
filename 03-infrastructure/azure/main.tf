# -----------------------------------------------------------------------------
# Hub-spoke model
# -----------------------------------------------------------------------------
# Het infra team richt de spoke in:
#   - VNet met IP ranges uit IPAM en route table naar de hub
#   - Resource group met juiste tags
#   - Beveiliging via de centrale hub firewall (geen NSGs op spoke-niveau)
#
# Wij maken onze resources aan binnen de bestaande VNet en resource group.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Bestaande Resource Group (aangemaakt door infra team)
# -----------------------------------------------------------------------------

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# -----------------------------------------------------------------------------
# Networking — subnets binnen bestaande spoke VNet
# -----------------------------------------------------------------------------

module "network" {
  source = "./modules/network"

  resource_group_name = data.azurerm_resource_group.main.name
  vnet_name           = var.vnet_name
  environment         = var.environment
  location_short      = var.location_short
  subnets             = var.subnets
}

# -----------------------------------------------------------------------------
# Data (Key Vault + Storage Account)
# -----------------------------------------------------------------------------

module "data" {
  source = "./modules/data"

  resource_group_name  = data.azurerm_resource_group.main.name
  location             = data.azurerm_resource_group.main.location
  project_name         = var.project_name
  environment          = var.environment
  location_short       = var.location_short
  storage_account_name = var.storage_account_name
  tags                 = var.tags
}

# -----------------------------------------------------------------------------
# Compute (VM + Docker Compose)
# -----------------------------------------------------------------------------

module "compute" {
  source = "./modules/compute"

  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  location_short      = var.location_short
  vm_size             = var.vm_size
  admin_username      = var.vm_admin_username
  ssh_public_key_path = var.vm_ssh_public_key_path
  subnet_id           = module.network.subnet_ids["app"]
  key_vault_id        = module.data.key_vault_id
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Monitoring (Log Analytics + Diagnostic Settings)
# -----------------------------------------------------------------------------

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name   = data.azurerm_resource_group.main.name
  location              = data.azurerm_resource_group.main.location
  project_name          = var.project_name
  environment           = var.environment
  location_short        = var.location_short
  retention_days        = var.log_analytics_retention_days
  key_vault_id          = module.data.key_vault_id
  storage_account_id    = module.data.storage_account_id
  subscription_id       = "/subscriptions/${var.subscription_id}"
  monthly_budget_amount = var.monthly_budget_amount
  budget_start_date     = var.budget_start_date
  budget_alert_emails   = var.budget_alert_emails
  tags                  = var.tags
}
