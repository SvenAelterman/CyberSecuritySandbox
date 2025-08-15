moved {
  from = azurerm_resource_group.analysis_rg
  to   = module.analysis_rg.azurerm_resource_group.this
}

moved {
  from = azurerm_resource_group.network_rg
  to   = module.network_rg.azurerm_resource_group.this
}

moved {
  from = azurerm_resource_group.dc_rg
  to   = module.dc_rg.azurerm_resource_group.this
}

module "network_rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"

  name     = replace(local.naming_structure, "{resourceType}", "rg-network")
  location = var.location
  tags     = var.tags
}

module "dc_rg" {
  count = var.deploy_dc ? 1 : 0

  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"

  name     = replace(local.naming_structure, "{resourceType}", "rg-dc")
  location = var.location
  tags     = var.tags
}

module "analysis_rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"

  name     = replace(local.naming_structure, "{resourceType}", "rg-analysis")
  location = var.location
  tags     = var.tags
}

module "support_rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"

  name     = replace(local.naming_structure, "{resourceType}", "rg-support")
  location = var.location
  tags     = var.tags
}
