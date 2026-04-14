# =============================================================================
# Sjabloon — Jouw Organisatie waarden
# =============================================================================
# Andere gemeenten: kopieer dit bestand en pas de waarden aan voor jouw omgeving.
# =============================================================================

subscription_id = "00000000-0000-0000-0000-000000000000" # Vul hier je Azure subscription ID in

location       = "westeurope"
location_short = "weu"
project_name   = "ai"
environment    = "dev"

# --- Hub-spoke: bestaande resources van infra team ---
# De resource group en VNet worden aangemaakt door het infra team.
# IP ranges komen uit IPAM. Vul hier de door hen opgegeven namen in.
resource_group_name = "rg-myapp-dev-weu"      # WIJZIG DIT: naam van de door infra aangemaakte RG
vnet_name           = "vnet-spoke-ai-dev"    # WIJZIG DIT: naam van de door infra aangemaakte spoke VNet

# --- Subnets (address prefixes uit IPAM) ---
# WIJZIG DIT: vul de door infra team toegewezen IP ranges in
subnets = {
  app = {
    address_prefixes = ["10.0.1.0/24"]
  }
  sandbox = {
    address_prefixes = ["10.0.2.0/24"]
  }
  data = {
    address_prefixes = ["10.0.3.0/24"]
  }
}

# --- Compute ---
vm_size           = "Standard_B2ms"
vm_admin_username = "azureadmin"

# --- Data ---
storage_account_name = "stmyappdevweu" # Moet wereldwijd uniek zijn — pas aan indien bezet

# --- Monitoring & Budget ---
log_analytics_retention_days = 90
monthly_budget_amount        = 150
budget_start_date            = "2026-04-01"
budget_alert_emails          = ["ai-team@jouworganisatie.nl"] # WIJZIG DIT: vul echte e-mailadressen in

# --- Tags ---
# Basisset tags wordt overgenomen van de resource group (infra team).
# Hieronder eventuele aanvullende tags.
tags = {
  eigenaar     = "ai-team"
  project      = "myapp"
  kostenplaats = "1234-AI"
  fase         = "sandbox"
  omgeving     = "dev"
}
