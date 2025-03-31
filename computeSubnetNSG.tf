locals {
  computeSubnet_nsg_rules = {
    "Allow_Bastion_Inbound" = {
      name                       = "Allow_Bastion_Inbound"
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["22", "3389"]
      direction                  = "Inbound"
      priority                   = 150
      protocol                   = "Tcp"
      source_address_prefix      = module.virtualnetwork.subnets[local.subnet_names.AzureBastionSubnet].resource.output.properties.addressPrefixes[0]
      source_port_range          = "*"
    }
  }
}

# This is the module call
module "computeSubnet_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.4.0"

  name                = "computeSubnet-demo-nsg-cnc-01"
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name

  security_rules = local.computeSubnet_nsg_rules

  enable_telemetry = var.telemetry_enabled
}
