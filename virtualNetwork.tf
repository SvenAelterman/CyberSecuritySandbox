module "virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  // DO NOT SET DNS IPs HERE

  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = "soc-demo-vnet-cnc-01"
  resource_group_name = azurerm_resource_group.network_rg.name
  subnets = {
    "AzureFirewallSubnet" = {
      name = local.subnet_names.AzureFirewallSubnet
      // TODO: Calculate subnet CIDRS using the TF functions
      address_prefixes = ["10.0.0.0/26"]
    }
    "AzureFirewallManagementSubnet" = {
      name             = local.subnet_names.AzureFirewallManagementSubnet
      address_prefixes = ["10.0.0.64/26"]
    }
    "AzureBastionSubnet" = {
      name             = local.subnet_names.AzureBastionSubnet
      address_prefixes = ["10.0.0.128/26"]
    }
    "ComputeSubnet" = {
      name             = local.subnet_names.ComputeSubnet
      address_prefixes = ["10.0.0.192/26"]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
      // TODO: Disable default
      default_outbound_access_enabled = true
    }
    "DomainControllerSubnet" = {
      name             = local.subnet_names.DomainControllerSubnet
      address_prefixes = ["10.0.1.0/26"]
      network_security_group = {
        id = module.domainControllerSubnetSubnet_nsg.resource.id
      }
      // TODO: Disable default
      default_outbound_access_enabled = true
    }
  }
  enable_telemetry = var.telemetry_enabled
}

# output "AzureBastionSubnetResource" {
#   value = module.virtualnetwork.subnets["AzureBastionSubnet"].resource
# }

# output "AzureBastionSubnetId" {
#   value = module.virtualnetwork.subnets["AzureBastionSubnet"].resource.output.id
# }
