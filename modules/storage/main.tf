resource "azurerm_storage_account" "app_data" {
  name                          = "stappdata2026eastus"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  tags                          = var.tags
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-storage-db"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-storage-blob"
    private_connection_resource_id = azurerm_storage_account.app_data.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}