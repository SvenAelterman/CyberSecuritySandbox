module "nat_gateway" {
  count = var.deploy_natgw ? 1 : 0

  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "~> 0.2.1"

  name                = replace(local.naming_structure, "{resourceType}", "ng")
  resource_group_name = module.network_rg.name
  location            = module.network_rg.resource.location
  tags                = var.tags

  # // TODO: Only associate with ComputeSubnet and DomainControllerSubnet if no firewall deployed
  # subnet_associations = {
  #   computeSubnet = {
  #     resource_id = module.virtualnetwork.subnets[local.subnet_names.ComputeSubnet].resource_id
  #   }
  #   AzureFirewallSubnet = {
  #     resource_id = module.virtualnetwork.subnets[local.subnet_names.AzureFirewallSubnet].resource_id
  #   }
  #   domainControllerSubnet = {
  #     resource_id = module.virtualnetwork.subnets[local.subnet_names.DomainControllerSubnet].resource_id
  #   }
  # }

  public_ip_configuration = {
    allocation_method = "Static"
    ip_version        = "IPv4"
    sku               = "Standard"
    zones             = ["1", "2", "3"]
  }

  public_ips = {
    ng_pip1 = {
      // TODO: Use naming structure
      name = "soc-demo-ng-pip1-cnc-01"
    }
  }

  enable_telemetry = var.telemetry_enabled
}
