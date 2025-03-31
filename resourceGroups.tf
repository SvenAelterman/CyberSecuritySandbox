# resource "azurerm_resource_group" "network_rg" {
#   name     = replace(local.naming_structure, "{resourceType}", "rg-network")
#   location = var.location
# }

# resource "azurerm_resource_group" "dc_rg" {
#   count = var.deploy_dc ? 1 : 0

#   name     = replace(local.naming_structure, "{resourceType}", "rg-dc")
#   location = var.location
# }

# resource "azurerm_resource_group" "analysis_rg" {
#   name     = replace(local.naming_structure, "{resourceType}", "rg-analysis")
#   location = var.location
# }

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
}
module "dc_rg" {
  count = var.deploy_dc ? 1 : 0

  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"

  name     = replace(local.naming_structure, "{resourceType}", "rg-dc")
  location = var.location
}

module "analysis_rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.1"

  name     = replace(local.naming_structure, "{resourceType}", "rg-analysis")
  location = var.location
}
