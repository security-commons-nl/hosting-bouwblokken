# --- Log Analytics Workspace ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-shared-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

# --- Diagnostic settings for Key Vault ---

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-keyvault"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# --- Budget Alert ---

resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "budget-${var.project_name}-${var.environment}-monthly"
  subscription_id = var.subscription_id
  amount          = var.monthly_budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThanOrEqualTo"
    contact_emails = var.budget_alert_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    contact_emails = var.budget_alert_emails
  }

  notification {
    enabled        = true
    threshold      = 120
    operator       = "GreaterThanOrEqualTo"
    contact_emails = var.budget_alert_emails
  }
}

# --- Azure Policy: Allowed Locations (West Europe only) ---

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "policy-allowed-locations"
  subscription_id      = var.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Allowed locations"
  enforce              = true

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [var.location]
    }
  })
}

# --- Azure Policy: Require secure transfer on Storage ---

resource "azurerm_subscription_policy_assignment" "secure_transfer" {
  name                 = "policy-secure-transfer-storage"
  subscription_id      = var.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  display_name         = "Secure transfer to storage accounts should be enabled"
  enforce              = true
}

# --- Azure Policy: Require tags ---

resource "azurerm_subscription_policy_assignment" "require_tag_eigenaar" {
  name                 = "policy-require-tag-eigenaar"
  subscription_id      = var.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Require tag: eigenaar"
  enforce              = true

  parameters = jsonencode({
    tagName = {
      value = "eigenaar"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "require_tag_project" {
  name                 = "policy-require-tag-project"
  subscription_id      = var.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Require tag: project"
  enforce              = true

  parameters = jsonencode({
    tagName = {
      value = "project"
    }
  })
}
