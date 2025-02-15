module "fw_public_ip" {
  source = "Azure/avm-res-network-publicipaddress/azurerm"

  name                = "soc-demo-fw-pip1-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "fw_mgmt_public_ip" {
  source = "Azure/avm-res-network-publicipaddress/azurerm"


  name                = "soc-demo-fw-pip2-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  enable_telemetry = var.telemetry_enabled
}

module "fwpolicy" {
  source = "Azure/avm-res-network-firewallpolicy/azurerm"

  name                = "soc-demo-fwpol-cnc-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name

  firewall_policy_sku = "Basic"

  enable_telemetry = var.telemetry_enabled

  // TODO: Create rule to allow accessing GitHub for DC script
}

module "firewall" {
  source = "Azure/avm-res-network-azurefirewall/azurerm"

  name                = "soc-demo-fw-cnc-01"
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  firewall_sku_tier   = "Basic"
  firewall_sku_name   = "AZFW_VNet"
  firewall_zones      = ["1", "2", "3"]

  firewall_ip_configuration = [
    {
      name                 = "ipconfig1"
      subnet_id            = module.avm-res-network-virtualnetwork.subnets["AzureFirewallSubnet"].resource.output.id
      public_ip_address_id = module.fw_public_ip.public_ip_id
    }
  ]

  firewall_management_ip_configuration = {
    name                 = "ipconfig_mgmt"
    subnet_id            = module.avm-res-network-virtualnetwork.subnets["AzureFirewallManagementSubnet"].resource.output.id
    public_ip_address_id = module.fw_mgmt_public_ip.public_ip_id
  }

  firewall_policy_id = module.fwpolicy.resource_id

  enable_telemetry = var.telemetry_enabled
}
