
locals {
  storage_account_name_prefix = length(var.storage_account_name_prefix) > 0 ? var.storage_account_name_prefix : [var.workload_name, var.environment]
  storage_account_name_suffix = length(var.storage_account_name_suffix) > 0 ? var.storage_account_name_suffix : [local.short_locations[var.location], var.instance]

  // Calculate how many unique characters we can generate and still have a valid storage account name
  unique_st_suffix_len = 24 - (length(join("", local.storage_account_name_suffix)) + length(join("", local.storage_account_name_prefix)) + length("st"))
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.0"

  suffix        = local.storage_account_name_suffix
  prefix        = local.storage_account_name_prefix
  unique-length = local.unique_st_suffix_len
}

module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.5.0"

  name                = module.naming.storage_account.name_unique
  location            = module.analysis_rg.resource.location
  resource_group_name = module.analysis_rg.name
  tags                = var.tags

  account_replication_type          = "LRS"
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = true
  public_network_access_enabled     = true

  containers = {
    "malware-sample" = {
      name                  = "malware-sample"
      container_access_type = "private"
    }
  }

  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    virtual_network_subnet_ids = [module.virtualnetwork.subnets["ComputeSubnet"].resource_id]
    ip_rules                   = local.storage_account_firewall_allowed_ip
  }

  enable_telemetry = var.telemetry_enabled
}
