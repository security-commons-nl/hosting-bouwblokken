data "azurerm_client_config" "current" {}

# --- Key Vault ---

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project_name}-${var.environment}-${var.location_short}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization  = true
  tags                       = var.tags
}

# Grant the deployer access to manage secrets
resource "azurerm_role_assignment" "deployer_keyvault_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# --- Storage Account ---

resource "azurerm_storage_account" "main" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  access_tier                   = "Hot"
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled    = true
  tags                          = var.tags

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.allowed_storage_ips
  }
}

# --- Storage container for documents ---

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
