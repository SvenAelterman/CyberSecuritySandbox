locals {
  vnet_address_space = "10.0.0.0/16"
  vnet_address_cidr  = tonumber(split("/", local.vnet_address_space)[1])
}

module "virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  // DO NOT SET DNS IPs HERE

  address_space       = [local.vnet_address_space]
  location            = var.location
  name                = "soc-demo-vnet-cnc-01"
  resource_group_name = azurerm_resource_group.network_rg.name

  subnets = {
    "${local.subnet_names.AzureFirewallSubnet}" = {
      name             = local.subnet_names.AzureFirewallSubnet
      address_prefixes = [cidrsubnet(local.vnet_address_space, 26 - 32 + local.vnet_address_cidr, 0)]
    }
    "${local.subnet_names.AzureFirewallManagementSubnet}" = {
      name             = local.subnet_names.AzureFirewallManagementSubnet
      address_prefixes = [cidrsubnet(local.vnet_address_space, 26 - 32 + local.vnet_address_cidr, 1)]
    }
    "${local.subnet_names.AzureBastionSubnet}" = {
      name             = local.subnet_names.AzureBastionSubnet
      address_prefixes = [cidrsubnet(local.vnet_address_space, 26 - 32 + local.vnet_address_cidr, 2)]
    }
    "${local.subnet_names.ComputeSubnet}" = {
      name             = local.subnet_names.ComputeSubnet
      address_prefixes = [cidrsubnet(local.vnet_address_space, 26 - 32 + local.vnet_address_cidr, 3)]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      service_endpoints = ["Microsoft.Storage"]
      // TODO: Disable default
      default_outbound_access_enabled = true
    }
    "${local.subnet_names.DomainControllerSubnet}" = {
      name             = local.subnet_names.DomainControllerSubnet
      address_prefixes = [cidrsubnet(local.vnet_address_space, 26 - 32 + local.vnet_address_cidr, 4)]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
      // TODO: Disable default
      default_outbound_access_enabled = true
    }
  }

  enable_telemetry = var.telemetry_enabled
}
