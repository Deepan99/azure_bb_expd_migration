# ------------------------------------------------------------------
# 1. User-Assigned Managed Identity
# ------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-app-spoke1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
