# ------------------------------------------------------------------
# 1. Enterprise Entra ID Security Groups
# ------------------------------------------------------------------
resource "azuread_group" "cloud_admins" {
  display_name     = "sg-cloud-admins"
  security_enabled = true
  description      = "Enterprise Cloud Administrators Group"
}

resource "azuread_group" "network_admins" {
  display_name     = "sg-network-admins"
  security_enabled = true
  description      = "Enterprise Network Operations & SRE Group"
}

resource "azuread_group" "sec_ops" {
  display_name     = "sg-sec-ops"
  security_enabled = true
  description      = "Enterprise InfoSec & Security Operations Group"
}

resource "azuread_group" "developers" {
  display_name     = "sg-developers"
  security_enabled = true
  description      = "Enterprise Application Developers Group"
}

resource "azuread_group" "iam_admins" {
  display_name     = "sg-iam-admins"
  security_enabled = true
  description      = "Enterprise IAM & Access Control Group"
}

resource "azuread_group" "audit_compliance" {
  display_name     = "sg-audit-compliance"
  security_enabled = true
  description      = "Enterprise Audit & Compliance Group"
}

# ------------------------------------------------------------------
# 2. User-Assigned Managed Identity
# ------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-app-spoke1"
  location            = var.location
  resource_group_name = "rg-spoke-app1-eastus"
  tags                = var.tags
}

# ------------------------------------------------------------------
# 3. Assign Subscription RBAC Roles to Security Groups
# ------------------------------------------------------------------
data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "cloud_admins_contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.cloud_admins.object_id
}

resource "azurerm_role_assignment" "network_admins_contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_group.network_admins.object_id
}

resource "azurerm_role_assignment" "sec_ops_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Security Reader"
  principal_id         = azuread_group.sec_ops.object_id
}

resource "azurerm_role_assignment" "developers_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.developers.object_id
}
