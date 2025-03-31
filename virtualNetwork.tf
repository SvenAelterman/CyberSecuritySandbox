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
    "${local.subnet_names.AzureFirewallSubnet}" = {
      name             = local.subnet_names.AzureFirewallSubnet
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 0)]
    }
    "${local.subnet_names.AzureFirewallManagementSubnet}" = {
      name             = local.subnet_names.AzureFirewallManagementSubnet
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 1)]
    }
    "${local.subnet_names.AzureBastionSubnet}" = {
      name             = local.subnet_names.AzureBastionSubnet
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 2)]
    }
    "${local.subnet_names.ComputeSubnet}" = {
      name             = local.subnet_names.ComputeSubnet
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 3)]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      service_endpoints = ["Microsoft.Storage"]
    }
    "${local.subnet_names.DomainControllerSubnet}" = {
      name             = local.subnet_names.DomainControllerSubnet
      address_prefixes = [cidrsubnet(var.vnet_address_space, 26 - local.vnet_address_cidr, 4)]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
    }
  }

  enable_telemetry = var.telemetry_enabled
}
