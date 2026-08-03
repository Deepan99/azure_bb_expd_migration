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

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

# ------------------------------------------------------------------
# Azure Firewall & Firewall Policy
# ------------------------------------------------------------------
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-fw-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "fw-policy-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "hub_fw" {
  name                = "afw-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.azure_firewall.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "rcg_spoke_egress" {
  name               = "rcg-spoke-egress"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 200

  network_rule_collection {
    name     = "allow-spoke-web-outbound"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-spoke-to-internet"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443", "53"]
    }
  }
}

# ------------------------------------------------------------------
# Route Table (UDR - Force Spoke Outbound to Azure Firewall)
# ------------------------------------------------------------------
resource "azurerm_route_table" "spoke_rt" {
  name                = "rt-spoke-to-firewall"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  route {
    name                   = "dg-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "web_assoc" {
  subnet_id      = azurerm_subnet.web.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

resource "azurerm_subnet_route_table_association" "db_assoc" {
  subnet_id      = azurerm_subnet.database.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

# ------------------------------------------------------------------
# Azure Bastion Host
# ------------------------------------------------------------------
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bas-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "hub_bastion" {
  name                = "bas-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

# ------------------------------------------------------------------
# Virtual Network Gateway (VPN)
# ------------------------------------------------------------------
resource "azurerm_public_ip" "vng_pip" {
  name                = "pip-vng-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "hub_vpn" {
  name                = "vng-hub-eastus"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1"
  tags                = var.tags

  ip_configuration {
    name                          = "vng-ip-config"
    public_ip_address_id          = azurerm_public_ip.vng_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# ------------------------------------------------------------------
# Centralized Private DNS Zone & VNet Links
# ------------------------------------------------------------------
resource "azurerm_private_dns_zone" "blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns_link" {
  name                  = "link-hub-vnet"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_dns_link" {
  name                  = "link-spoke-vnet"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

# ------------------------------------------------------------------
# VNet Peering with Gateway Transit Enabled
# ------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
}

# ------------------------------------------------------------------
# Enterprise Resource Locks (CanNotDelete Protection)
# ------------------------------------------------------------------
resource "azurerm_management_lock" "hub_lock" {
  name       = "lock-hub-no-delete"
  scope      = azurerm_resource_group.hub.id
  lock_level = "CanNotDelete"
  notes      = "Enterprise Guardrail: Blocks accidental deletion of Hub Infrastructure"
}

resource "azurerm_management_lock" "spoke_lock" {
  name       = "lock-spoke-no-delete"
  scope      = azurerm_resource_group.spoke.id
  lock_level = "CanNotDelete"
  notes      = "Enterprise Guardrail: Blocks accidental deletion of Spoke Infrastructure"
}