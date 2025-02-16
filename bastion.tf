module "bastion_public_ip" {
  source = "Azure/avm-res-network-publicipaddress/azurerm"

  name                = "soc-demo-bastion-pip1-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "bastion" {
  source = "Azure/avm-res-network-bastionhost/azurerm"

  enable_telemetry    = var.telemetry_enabled
  name                = "soc-demo-bastion-cnc-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  copy_paste_enabled  = true
  file_copy_enabled   = false
  sku                 = "Standard"
  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.virtualnetwork.subnets[local.subnet_names.AzureBastionSubnet].resource.output.id
    public_ip_address_id = module.bastion_public_ip.public_ip_id
  }
  ip_connect_enabled     = true
  scale_units            = 2
  shareable_link_enabled = false
  tunneling_enabled      = true
  kerberos_enabled       = true
}
