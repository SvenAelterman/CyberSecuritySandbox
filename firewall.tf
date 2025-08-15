module "fw_public_ip" {
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "~> 0.2.0"

  name                = replace(local.naming_structure, "{resourceType}", "pip-fw1")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "fw_mgmt_public_ip" {
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "~> 0.2.0"

  name                = replace(local.naming_structure, "{resourceType}", "pip-fw2")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "fwpolicy" {
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-firewallpolicy/azurerm"
  version = "~> 0.3.3"

  name                = replace(local.naming_structure, "{resourceType}", "fwpol")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  firewall_policy_sku = "Basic"

  enable_telemetry = var.telemetry_enabled

  // TODO: Create rule to allow accessing GitHub for DC script
}

module "fwpolicy_rulecollectiongroup" {
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  version = "~> 0.3.3"

  firewall_policy_rule_collection_group_firewall_policy_id = module.fwpolicy[0].resource.id
  firewall_policy_rule_collection_group_name               = "BaseRuleCollectionGroup"
  firewall_policy_rule_collection_group_priority           = 1000

  firewall_policy_rule_collection_group_network_rule_collection = [
    {
      action   = "Allow"
      name     = "NetworkRuleCollection"
      priority = 500
      rule = [
        {
          name                  = "OutboundHttpToInternet"
          description           = "Allow HTTP/HTTPS traffic outbound to the Internet"
          destination_addresses = ["0.0.0.0/0"]
          destination_ports     = ["80", "443"]
          source_addresses      = [var.vnet_address_space] // Allow traffic from all IPs on the virtual network
          source_ports          = ["*"]
          protocols             = ["TCP"]
        },
        // Note: this rule is currently unused but here for future reference
        {
          name                  = "OutboundDnsAzure"
          description           = "Allow DNS requests from DC subnet to Azure DNS"
          destination_addresses = ["168.63.129.16"]
          destination_ports     = ["53"]
          source_addresses      = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.DomainControllerSubnet]]
          source_ports          = ["*"]
          protocols             = ["UDP", "TCP"]
        },
        {
          name                  = "OutboundDnsInternet"
          description           = "Allow DNS requests from DC subnet to Internet DNS servers (for iterative queries using root servers)"
          destination_addresses = ["*"]
          destination_ports     = ["53"]
          source_addresses      = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.DomainControllerSubnet]]
          source_ports          = ["*"]
          protocols             = ["UDP", "TCP"]
        },
        {
          name                  = "OutboundAzureKms"
          description           = "Allow KMS activation"
          destination_addresses = ["20.118.99.224", "40.83.235.53"]
          destination_ports     = ["1688"]
          source_addresses      = [var.vnet_address_space]
          source_ports          = ["*"]
          protocols             = ["TCP"]
        }
      ]
    }
  ]
}

module "firewall" {
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "~> 0.3.0"

  name                = replace(local.naming_structure, "{resourceType}", "fw")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  firewall_sku_tier = "Basic"
  firewall_sku_name = "AZFW_VNet"
  firewall_zones    = ["1", "2", "3"]

  firewall_ip_configuration = [
    {
      name                 = "ipconfig1"
      subnet_id            = module.virtualnetwork.subnets[local.subnet_names.AzureFirewallSubnet].resource.output.id
      public_ip_address_id = module.fw_public_ip[0].public_ip_id
    }
  ]

  firewall_management_ip_configuration = {
    name                 = "ipconfig_mgmt"
    subnet_id            = module.virtualnetwork.subnets[local.subnet_names.AzureFirewallManagementSubnet].resource.output.id
    public_ip_address_id = module.fw_mgmt_public_ip[0].public_ip_id
  }

  firewall_policy_id = module.fwpolicy[0].resource_id

  enable_telemetry = var.telemetry_enabled
}

// Create a rule on the existing route table to route Internet-bound traffic to the Firewall's private IP
resource "azurerm_route" "fw_route" {
  count = var.deploy_firewall ? 1 : 0

  name                = "default"
  resource_group_name = module.network_rg.name
  route_table_name    = module.rt[0].name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.firewall[0].resource.ip_configuration[0].private_ip_address
}
