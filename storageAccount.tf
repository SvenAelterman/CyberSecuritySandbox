module "storage" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  name                = "socdemostcnc01"
  location            = azurerm_resource_group.analysis_rg.location
  resource_group_name = azurerm_resource_group.analysis_rg.name

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
    virtual_network_subnet_ids = [module.virtualnetwork.subnets[local.subnet_names.ComputeSubnet].resource_id]
    ip_rules                   = [data.http.runner_ip.response_body]
  }

  enable_telemetry = var.telemetry_enabled
}
