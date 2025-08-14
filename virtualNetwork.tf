locals {
  vnet_address_cidr = tonumber(split("/", var.vnet_address_space)[1])
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0.0"

  base_cidr_block = var.vnet_address_space
  networks = [
    {
      name = local.subnet_names.AzureFirewallSubnet
      // The number of additional bits needed for the subnet CIDR
      // is the desired size of the subnet (e.g., 26) subtracted from the current VNet CIDR
      // Example: if the VNet CIDR is /24 and the subnet CIDR should be /26, then 2 additional bits are needed
      new_bits = 26 - local.vnet_address_cidr
    },
    {
      name     = local.subnet_names.AzureFirewallManagementSubnet
      new_bits = 26 - local.vnet_address_cidr
    },
    {
      name     = local.subnet_names.AzureBastionSubnet
      new_bits = 26 - local.vnet_address_cidr
    },
    {
      name     = local.subnet_names.ComputeSubnet
      new_bits = 26 - local.vnet_address_cidr
    },
    {
      name     = local.subnet_names.DomainControllerSubnet
      new_bits = 26 - local.vnet_address_cidr
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
    "${local.subnet_names.AzureFirewallSubnet}" = {
      name             = local.subnet_names.AzureFirewallSubnet
      address_prefixes = [module.subnet_addrs.network_cidr_blocks[local.subnet_names.AzureFirewallSubnet]]
    }
    "${local.subnet_names.AzureFirewallManagementSubnet}" = {
      name             = local.subnet_names.AzureFirewallManagementSubnet
      address_prefixes = [module.subnet_addrs.network_cidr_blocks[local.subnet_names.AzureFirewallManagementSubnet]]
    }
    "${local.subnet_names.AzureBastionSubnet}" = {
      name             = local.subnet_names.AzureBastionSubnet
      address_prefixes = [module.subnet_addrs.network_cidr_blocks[local.subnet_names.AzureBastionSubnet]]
    }
    "${local.subnet_names.ComputeSubnet}" = {
      name             = local.subnet_names.ComputeSubnet
      address_prefixes = [module.subnet_addrs.network_cidr_blocks[local.subnet_names.ComputeSubnet]]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      service_endpoints = ["Microsoft.Storage"]
    }
    "${local.subnet_names.DomainControllerSubnet}" = {
      name             = local.subnet_names.DomainControllerSubnet
      address_prefixes = [module.subnet_addrs.network_cidr_blocks[local.subnet_names.DomainControllerSubnet]]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
    }
  }

  enable_telemetry = var.telemetry_enabled
}
