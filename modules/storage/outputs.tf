output "storage_account_name" {
  value = azurerm_storage_account.app_data.name
}

output "storage_account_id" {
  value = azurerm_storage_account.app_data.id
}

output "storage_primary_blob_endpoint" {
  value = azurerm_storage_account.app_data.primary_blob_endpoint
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.storage_pe.id
}
