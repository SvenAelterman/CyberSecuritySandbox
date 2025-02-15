resource "azurerm_resource_group" "network_rg" {
  name     = "soc-network-demo-rg-cnc-01"
  location = var.location
}

resource "azurerm_resource_group" "dc_rg" {
  name     = "soc-dc-demo-rg-cnc-01"
  location = var.location
}
resource "azurerm_resource_group" "analysis_rg" {
  name     = "soc-analysis-demo-rg-cnc-01"
  location = var.location
}
