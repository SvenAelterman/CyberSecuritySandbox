module "rt" {
  source = "Azure/avm-res-network-routetable/azurerm"

  enable_telemetry    = var.telemetry_enabled
  name                = "soc-demo-rt-cnc-01"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location

  routes = {
    default = {
      name                   = "default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall.resource.ip_configuration[0].private_ip_address
    },
    kms01 = {
      name           = "kms01"
      address_prefix = "40.83.235.53/32"
      next_hop_type  = "Internet"
    },
    kms02 = {
      name           = "kms02"
      address_prefix = "20.118.99.224/32"
      next_hop_type  = "Internet"
    }
  }

  subnet_resource_ids = {
    subnet1 = module.virtualnetwork.subnets[local.subnet_names.DomainControllerSubnet].resource.output.id,
    subnet2 = module.virtualnetwork.subnets[local.subnet_names.ComputeSubnet].resource_id
  }

  depends_on = [module.firewall]
}
