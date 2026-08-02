output "spoke_resource_group_name" { value = azurerm_resource_group.spoke.name }
output "spoke_location" { value = azurerm_resource_group.spoke.location }
output "spoke_vnet_id" { value = azurerm_virtual_network.spoke.id }
output "web_subnet_id" { value = azurerm_subnet.web.id }
output "db_subnet_id" { value = azurerm_subnet.database.id }