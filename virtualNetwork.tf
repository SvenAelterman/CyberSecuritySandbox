locals {
  vnet_address_cidr = tonumber(split("/", var.vnet_address_space)[1])

  firewall_subnet = var.deploy_firewall ? {
    "${local.subnet_names.AzureFirewallSubnet}" = {
      name             = local.subnet_names.AzureFirewallSubnet
      address_prefixes = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.AzureFirewallSubnet]]
      nat_gateway = var.deploy_natgw ? {
        id = module.nat_gateway[0].resource_id
      } : {}
    }
  } : {}

  firewall_mgt_subnet = var.deploy_firewall ? {
    "${local.subnet_names.AzureFirewallManagementSubnet}" = {
      name             = local.subnet_names.AzureFirewallManagementSubnet
      address_prefixes = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.AzureFirewallManagementSubnet]]
    }
  } : {}

  bastion_subnet = var.deploy_bastion ? {
    "${local.subnet_names.AzureBastionSubnet}" = {
      name             = local.subnet_names.AzureBastionSubnet
      address_prefixes = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.AzureBastionSubnet]]
    }
  } : {}

  dc_subnet = var.deploy_dc ? {
    "${local.subnet_names.DomainControllerSubnet}" = {
      name             = local.subnet_names.DomainControllerSubnet
      address_prefixes = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.DomainControllerSubnet]]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
      nat_gateway = var.deploy_natgw ? {
        id = module.nat_gateway[0].resource_id
      } : {}
      route_table = var.deploy_firewall ? {
        id = module.rt[0].resource_id
      } : {}
    }
  } : {}

  default_subnets = {
    # Always deploy the ComputeSubnet
    "${local.subnet_names.ComputeSubnet}" = {
      name             = local.subnet_names.ComputeSubnet
      address_prefixes = [module.subnet_addresses.network_cidr_blocks[local.subnet_names.ComputeSubnet]]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      nat_gateway = var.deploy_natgw ? {
        id = module.nat_gateway[0].resource_id
      } : {}
      route_table = var.deploy_firewall ? {
        id = module.rt[0].resource_id
      } : {}
      # Added Microsoft.KeyVault to service_endpoints to allow resources in the ComputeSubnet to securely access Azure Key Vault over the Azure backbone network.
      # This change is required for [insert business/technical reason, e.g., VM-managed identities accessing secrets/certificates].
      # Note: Adding this endpoint affects network access patterns and should be reviewed for compliance and security.
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
  }

  subnets = merge(local.default_subnets, local.firewall_subnet, local.firewall_mgt_subnet, local.bastion_subnet, local.dc_subnet)
}

// Calculate CIDR ranges for all possible subnets, though not all subnets may be created.
// This prevents issues if the deployment is later updated to include additional components
// because the address space won't change
module "subnet_addresses" {
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
  subnets       = local.subnets

  enable_telemetry = var.telemetry_enabled
}
