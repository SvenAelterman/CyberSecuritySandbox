module "fw_public_ip" {
  source = "Azure/avm-res-network-publicipaddress/azurerm"

  name                = "soc-demo-fw-pip1-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "fw_mgmt_public_ip" {
  source = "Azure/avm-res-network-publicipaddress/azurerm"


  name                = "soc-demo-fw-pip2-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "fwpolicy" {
  source = "Azure/avm-res-network-firewallpolicy/azurerm"

  name                = "soc-demo-fwpol-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name

  firewall_policy_sku = "Basic"

  enable_telemetry = var.telemetry_enabled

  // TODO: Create rule to allow accessing GitHub for DC script
}

module "fwpolicy_rulecollectiongroup" {
  source = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"

  firewall_policy_rule_collection_group_firewall_policy_id = module.fwpolicy.resource.id
  firewall_policy_rule_collection_group_name               = "BaseRuleCollectionGroup"
  firewall_policy_rule_collection_group_priority           = 1000

  firewall_policy_rule_collection_group_network_rule_collection = [
    {
      action   = "Allow"
      name     = "NetworkRuleCollection"
      priority = 500
      rule = [
        {
          name                  = "OutboundToInternet"
          description           = "Allow traffic outbound to the Internet"
          destination_addresses = ["0.0.0.0/0"]
          destination_ports     = ["80", "443"]
          source_addresses      = module.virtualnetwork.resource.output.properties.addressSpace.addressPrefixes // Allow traffic from all IPs on the virtual network
          source_ports          = ["*"]
          protocols             = ["TCP"]
        },
        // Note: this rule is currently unused but here for future reference
        {
          name                  = "OutboundDnsAzure"
          description           = "Allow DNS requests from DC subnet to Azure DNS"
          destination_addresses = ["168.63.129.16"]
          destination_ports     = ["53"]
          source_addresses      = module.virtualnetwork.subnets[local.subnet_names.DomainControllerSubnet].resource.output.properties.addressPrefixes
          source_ports          = ["*"]
          protocols             = ["UDP", "TCP"]
        },
        {
          name                  = "OutboundDnsRootServers"
          description           = "Allow DNS requests from DC subnet to Internet root servers"
          destination_addresses = ["*"]
          destination_ports     = ["53"]
          source_addresses      = module.virtualnetwork.subnets[local.subnet_names.DomainControllerSubnet].resource.output.properties.addressPrefixes
          source_ports          = ["*"]
          protocols             = ["UDP", "TCP"]
        }
      ]
    }
  ]
}

module "firewall" {
  source = "Azure/avm-res-network-azurefirewall/azurerm"

  name                = "soc-demo-fw-cnc-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  firewall_sku_tier   = "Basic"
  firewall_sku_name   = "AZFW_VNet"
  firewall_zones      = ["1", "2", "3"]

  firewall_ip_configuration = [
    {
      name                 = "ipconfig1"
      subnet_id            = module.virtualnetwork.subnets[local.subnet_names.AzureFirewallSubnet].resource.output.id
      public_ip_address_id = module.fw_public_ip.public_ip_id
    }
  ]

  firewall_management_ip_configuration = {
    name                 = "ipconfig_mgmt"
    subnet_id            = module.virtualnetwork.subnets[local.subnet_names.AzureFirewallManagementSubnet].resource.output.id
    public_ip_address_id = module.fw_mgmt_public_ip.public_ip_id
  }

  firewall_policy_id = module.fwpolicy.resource_id

  enable_telemetry = var.telemetry_enabled
}

# output "vnet" {
#   value = module.virtualnetwork.resource
# }
