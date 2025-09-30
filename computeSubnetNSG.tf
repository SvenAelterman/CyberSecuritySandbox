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
      source_address_prefix      = module.subnet_addresses.network_cidr_blocks[local.subnet_names.AzureBastionSubnet]
      source_port_range          = "*"
    }
  }
}

# This is the module call
module "computeSubnet_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.4.0"

  name                = replace(local.naming_structure, "{resourceType}", "nsg-computeSubnet")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  security_rules = local.computeSubnet_nsg_rules

  enable_telemetry = var.telemetry_enabled
}
