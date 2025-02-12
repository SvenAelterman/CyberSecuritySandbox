module "avm-res-network-virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = "soc-demo-vnet-cnc-01"
  resource_group_name = azurerm_resource_group.network_rg.name
  subnets = {
    "AzureFirewallSubnet" = {
      name = "AzureFirewallSubnet"
      // TODO: Calculate subnet CIDRS using the TF functions
      address_prefixes = ["10.0.0.0/26"]
    }
    "AzureFirewallManagementSubnet" = {
      name             = "AzureFirewallManagementSubnet"
      address_prefixes = ["10.0.0.64/26"]
    }
    "AzureBastionSubnet" = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.0.128/26"]
    }
    "ComputeSubnet" = {
      name             = "ComputeSubnet"
      address_prefixes = ["10.0.0.192/26"]
      network_security_group = {
        id = module.computeSubnet_nsg.resource.id
      }
    }
    "DomainControllerSubnet" = {
      name             = "DomainControllerSubnet"
      address_prefixes = ["10.0.1.0/26"]
    }
  }
  enable_telemetry = var.telemetry_enabled
}

# output "AzureBastionSubnetResource" {
#   value = module.avm-res-network-virtualnetwork.subnets["AzureBastionSubnet"].resource
# }

# output "AzureBastionSubnetId" {
#   value = module.avm-res-network-virtualnetwork.subnets["AzureBastionSubnet"].resource.output.id
# }
