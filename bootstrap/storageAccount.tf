variable "st_suffix" {
  default = ["socdemo", "state"]
  type    = list(any)
}

locals {
  unique_st_suffix_len = 24 - (length(var.st_suffix) + length("st"))
}

module "naming" {
  source        = "Azure/naming/azurerm"
  version       = "0.4.0"
  suffix        = var.st_suffix
  unique-length = local.unique_st_suffix_len
}

data "azurerm_client_config" "current" {}

locals {
  user_principals         = [data.azurerm_client_config.current.object_id]
  user_managed_identities = length(var.managed_id) > 0 ? [var.managed_id] : []
  any_principals          = toset(concat(local.user_principals, local.user_managed_identities))
}


resource "azurerm_role_assignment" "storage_account_contributor" {
  for_each                         = local.any_principals
  scope                            = module.storage.resource_id
  role_definition_name             = "Storage Account Contributor"
  principal_id                     = each.key
  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  for_each                         = local.any_principals
  scope                            = module.storage.containers["tfstate"].id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = each.key
  skip_service_principal_aad_check = false
}


module "storage" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  name                = module.naming.storage_account.name_unique
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  account_replication_type          = "LRS"
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = true
  public_network_access_enabled     = true

  containers = {
    tfstate = {
      name                  = "tfstate"
      container_access_type = "private"
    }
  }

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = [data.http.runner_ip.response_body]
  }

  enable_telemetry = var.telemetry_enabled
}
