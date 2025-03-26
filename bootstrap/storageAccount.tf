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

      role_assignments = {
        storage_blob_data_owner = {
          role_definition_id_or_name       = "Storage Blob Data Owner"
          principal_id                     = coalesce(var.managed_id, data.azurerm_client_config.current.object_id)
          skip_service_principal_aad_check = false
        }
      }
    }

  }

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = [data.http.runner_ip.response_body]
  }

  role_assignments = {
    storage_account_owner = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = coalesce(var.managed_id, data.azurerm_client_config.current.object_id)
      skip_service_principal_aad_check = false
    }
  }

  enable_telemetry = var.telemetry_enabled
}
