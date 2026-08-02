output "user_managed_identity_id" {
  value       = azurerm_user_assigned_identity.app_identity.id
  description = "User Managed Identity ID"
}

output "user_managed_identity_principal_id" {
  value       = azurerm_user_assigned_identity.app_identity.principal_id
  description = "User Managed Identity Principal ID"
}
