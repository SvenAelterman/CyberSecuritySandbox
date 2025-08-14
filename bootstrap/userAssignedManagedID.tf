
module "userassignedidentity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.3"

  count               = var.system_assigned_managed_id == "" ? 1 : 0
  name                = local.resource_names["user_assigned_managed_identity"]
  location            = azurerm_resource_group.managed_id.location
  resource_group_name = azurerm_resource_group.managed_id.name
}

resource "azurerm_role_assignment" "storage_account_contributor_userassignedidentity" {
  count                = var.system_assigned_managed_id == "" ? 1 : 0
  scope                = module.storage.resource_id
  role_definition_name = "Storage Account Contributor"
  # NB, since we used count meta-argument to create identity, we need to use index 0 to de-reference
  principal_id                     = module.userassignedidentity[0].principal_id
  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "storage_blob_data_contributor_userassignedidentity" {
  count                = var.system_assigned_managed_id == "" ? 1 : 0
  scope                = module.storage.containers["tfstate"].id
  role_definition_name = "Storage Blob Data Contributor"
  # NB, since we used count meta-argument to create identity, we need to use index 0 to de-reference
  principal_id                     = module.userassignedidentity[0].principal_id
  skip_service_principal_aad_check = false
}
