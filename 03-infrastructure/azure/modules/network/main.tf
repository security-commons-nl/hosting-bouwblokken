# -----------------------------------------------------------------------------
# Network module — Hub-spoke model
# -----------------------------------------------------------------------------
# De VNet en route table worden aangemaakt door het infra team (hub-spoke).
# Dit module maakt alleen subnets aan binnen de bestaande VNet.
# Beveiliging loopt via de centrale hub firewall — geen NSGs op spoke-niveau.
# -----------------------------------------------------------------------------

data "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "snet-${each.key}-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
}
