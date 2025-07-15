resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_names["resource_group_state_name"]
  location = var.location
}
