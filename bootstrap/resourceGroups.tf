resource "azurerm_resource_group" "bootstrap" {
  name     = "soc-bootstrap-demo-rg-cnc-01"
  location = var.location
}
