# ------------------------------------------------------------------
# State Migration Blocks (Tells Terraform code moved into modules)
# ------------------------------------------------------------------

moved {
  from = azurerm_resource_group.hub
  to   = module.networking.azurerm_resource_group.hub
}

moved {
  from = azurerm_resource_group.spoke
  to   = module.networking.azurerm_resource_group.spoke
}

moved {
  from = azurerm_virtual_network.hub
  to   = module.networking.azurerm_virtual_network.hub
}

moved {
  from = azurerm_virtual_network.spoke
  to   = module.networking.azurerm_virtual_network.spoke
}

moved {
  from = azurerm_subnet.shared_services
  to   = module.networking.azurerm_subnet.shared_services
}

moved {
  from = azurerm_subnet.azure_firewall
  to   = module.networking.azurerm_subnet.azure_firewall
}

moved {
  from = azurerm_subnet.gateway
  to   = module.networking.azurerm_subnet.gateway
}

moved {
  from = azurerm_subnet.web
  to   = module.networking.azurerm_subnet.web
}

moved {
  from = azurerm_subnet.database
  to   = module.networking.azurerm_subnet.database
}

moved {
  from = azurerm_virtual_network_peering.hub_to_spoke
  to   = module.networking.azurerm_virtual_network_peering.hub_to_spoke
}

moved {
  from = azurerm_virtual_network_peering.spoke_to_hub
  to   = module.networking.azurerm_virtual_network_peering.spoke_to_hub
}