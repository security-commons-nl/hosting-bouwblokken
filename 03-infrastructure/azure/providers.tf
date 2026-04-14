terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # --- Remote state in Azure Storage ---
  # Pas onderstaande waarden aan na overleg met infra team.
  # Uncomment wanneer de storage account voor state beschikbaar is.
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstatejouworg"
  #   container_name       = "tfstate"
  #   key                  = "jouw-ai-dev.tfstate"
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }

  subscription_id = var.subscription_id
}
