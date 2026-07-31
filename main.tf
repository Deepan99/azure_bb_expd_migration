# ------------------------------------------------------------------
# 1. Resource Group Declarations
# ------------------------------------------------------------------
resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-connectivity-eastus"
  location = var.location
  tags     = merge(var.tags, { Department = "IT-Networking" })
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-spoke-app1-eastus"
  location = var.location
  tags     = merge(var.tags, { Department = "Ecommerce" })
}

# ------------------------------------------------------------------
# 2. Hub Virtual Network & Subnets (10.0.0.0/16)
# ------------------------------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "shared_services" {
  name                 = "SharedServicesSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "azure_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ------------------------------------------------------------------
# 3. Spoke Virtual Network & Subnets (10.1.0.0/16)
# ------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-app1-eastus"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = ["10.1.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "web" {
  name                 = "WebSubnet"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "database" {
  name                 = "DatabaseSubnet"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.2.0/24"]
}

# ------------------------------------------------------------------
# 4. Bidirectional VNet Peering
# ------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ==================================================================
# 5. BULK IMPORT BLOCKS (Connects existing Portal resources to code!)
# ==================================================================

import {
  to = azurerm_resource_group.hub
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-hub-connectivity-eastus"
}

import {
  to = azurerm_resource_group.spoke
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-spoke-app1-eastus"
}

import {
  to = azurerm_virtual_network.hub
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-hub-connectivity-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus"
}

import {
  to = azurerm_virtual_network.spoke
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-spoke-app1-eastus/providers/Microsoft.Network/virtualNetworks/vnet-spoke-app1-eastus"
}

import {
  to = azurerm_subnet.shared_services
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-hub-connectivity-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus/subnets/SharedServicesSubnet"
}

import {
  to = azurerm_subnet.azure_firewall
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-hub-connectivity-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus/subnets/AzureFirewallSubnet"
}

import {
  to = azurerm_subnet.gateway
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-hub-connectivity-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus/subnets/GatewaySubnet"
}

import {
  to = azurerm_subnet.web
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-spoke-app1-eastus/providers/Microsoft.Network/virtualNetworks/vnet-spoke-app1-eastus/subnets/WebSubnet"
}

import {
  to = azurerm_subnet.database
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-spoke-app1-eastus/providers/Microsoft.Network/virtualNetworks/vnet-spoke-app1-eastus/subnets/DatabaseSubnet"
}

import {
  to = azurerm_virtual_network_peering.hub_to_spoke
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-hub-connectivity-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-eastus/virtualNetworkPeerings/peer-hub-to-spoke1"
}

import {
  to = azurerm_virtual_network_peering.spoke_to_hub
  id = "/subscriptions/17c3aa03-3446-4356-b8df-227a9834823f/resourceGroups/rg-spoke-app1-eastus/providers/Microsoft.Network/virtualNetworks/vnet-spoke-app1-eastus/virtualNetworkPeerings/peer-spoke1-to-hub"
}