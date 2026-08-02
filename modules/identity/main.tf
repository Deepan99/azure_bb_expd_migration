# ------------------------------------------------------------------
# 1. User-Assigned Managed Identity
# ------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-app-spoke1"
  location            = var.location
  resource_group_name = "rg-spoke-app1-eastus"
  tags                = var.tags
}
