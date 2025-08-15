locals {
  // Well-known IP addresses to be used in Azure
  // https://learn.microsoft.com/troubleshoot/azure/virtual-machines/windows/custom-routes-enable-kms-activation#solution
  kms_ips = ["40.83.235.53/32", "20.118.99.224/32", "23.102.135.246/32"]
}

module "rt" {
  count = var.deploy_firewall ? 1 : 0

  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "~> 0.4.1"

  name                = replace(local.naming_structure, "{resourceType}", "rt")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  enable_telemetry = var.telemetry_enabled
}

resource "azurerm_route" "kms_routes" {
  count = var.deploy_firewall ? length(local.kms_ips) : 0

  name                = "kms_${count.index + 1}"
  resource_group_name = module.network_rg.name
  route_table_name    = module.rt[0].name

  address_prefix = local.kms_ips[count.index]
  next_hop_type  = "Internet"
}
