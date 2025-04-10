module "bastion_public_ip" {
  count = var.deploy_bastion ? 1 : 0

  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "~> 0.2.0"

  name                = replace(local.naming_structure, "{resourceType}", "pip-bas")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"

  zones = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "bastion" {
  count = var.deploy_bastion ? 1 : 0

  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "~> 0.6.0"

  name                = replace(local.naming_structure, "{resourceType}", "bas")
  location            = module.network_rg.resource.location
  resource_group_name = module.network_rg.name
  tags                = var.tags

  copy_paste_enabled     = true
  file_copy_enabled      = false
  sku                    = "Basic"
  ip_connect_enabled     = false
  shareable_link_enabled = false
  tunneling_enabled      = false
  kerberos_enabled       = false
  #scale_units            = 2

  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.virtualnetwork.subnets[local.subnet_names.AzureBastionSubnet].resource.output.id
    public_ip_address_id = module.bastion_public_ip[0].public_ip_id
  }

  enable_telemetry = var.telemetry_enabled

  // To enable Kerberos, deploy Bastion AFTER setting custom DNS
  // https://learn.microsoft.com/en-us/azure/bastion/kerberos-authentication-portal
  depends_on = [azurerm_virtual_network_dns_servers.vnet_dns]
}
