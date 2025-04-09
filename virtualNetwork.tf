locals {
  vnet_address_cidr = tonumber(split("/", var.vnet_address_space)[1])
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
    "${"AzureFirewallSubnet"}" = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 0)]
    }
    "${"AzureFirewallManagementSubnet"}" = {
      name             = "AzureFirewallManagementSubnet"
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 1)]
    }
    "${"AzureBastionSubnet"}" = {
      name             = "AzureBastionSubnet"
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 2)]
    }
    "${"ComputeSubnet"}" = {
      name             = "ComputeSubnet"
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 3)]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      service_endpoints = ["Microsoft.Storage"]
    }
    "${"DomainControllerSubnet"}" = {
      name             = "DomainControllerSubnet"
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 4)]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
    }
  }

  enable_telemetry = var.telemetry_enabled
}
