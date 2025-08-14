resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_names["resource_group_state_name"]
  location = var.location
}
resource "azurerm_resource_group" "managed_id" {
  name     = local.resource_names["resource_group_identity_name"]
  location = var.location
}
