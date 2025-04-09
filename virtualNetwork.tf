module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"
  version = "~> 1.0.0"

  base_cidr_block = var.vnet_address_space
  networks = [
    {
      name     = "AzureFirewallSubnet"
      new_bits = 10
    },
    {
      name     = "AzureFirewallManagementSubnet"
      new_bits = 10
    },
    {
      name     = "AzureBastionSubnet"
      new_bits = 10
    },
    {
      name     = "ComputeSubnet"
      new_bits = 10
    },
    {
      name     = "DomainControllerSubnet"
      new_bits = 10
    },
  ]
}


module "virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.8.1"

  // DO NOT SET DNS IPs HERE

  location            = module.network_rg.resource.location
  name                = replace(local.naming_structure, "{resourceType}", "vnet")
  resource_group_name = module.network_rg.name
  tags                = var.tags

  address_space = [var.vnet_address_space]

  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureFirewallSubnet"]]
    }
    AzureFirewallManagementSubnet = {
      name             = "AzureFirewallManagementSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureFirewallManagementSubnet"]]
    }
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]]
    }
    ComputeSubnet = {
      name             = "ComputeSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["ComputeSubnet"]]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      service_endpoints = ["Microsoft.Storage"]
    }
    DomainControllerSubnet = {
      name             = "DomainControllerSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["DomainControllerSubnet"]]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
    }
  }

  enable_telemetry = var.telemetry_enabled
}
