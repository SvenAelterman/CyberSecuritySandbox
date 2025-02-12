resource "azurerm_resource_group" "network_rg" {
  name     = "soc-network-demo-rg-cnc-01"
  location = var.location
}
