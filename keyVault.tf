locals {
  // The passwords are conditionally generated,
  // so we need to handle creating the KV secrets conditionally
  analysis_vm_password_secret = var.deploy_windows_vm ? { analysis_vm_password = { name = "analysis-vm-password" } } : {}
  dc_vm_password_secret       = var.deploy_dc ? { dc_vm_password = { name = "dc-vm-password" } } : {}

  analysis_vm_password_value = var.deploy_windows_vm ? { analysis_vm_password = random_password.analysis_vm_admin_password[0].result } : {}
  dc_vm_password_value       = var.deploy_dc ? { dc_vm_password = random_password.dc_admin_password[0].result } : {}
}

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10.1"

  // TODO: Use sophisticated naming module
  name                = replace(local.naming_structure, "{resourceType}", "kv")
  resource_group_name = module.support_rg.name
  location            = module.support_rg.resource.location
  tags                = var.tags

  tenant_id = data.azurerm_client_config.current.tenant_id

  # These settings are acceptable because these are short-lived, throw-away sandbox environments
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  public_network_access_enabled = true
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"

    # Must allow access from the local IP so that the passwords can be retrieved for use with Bastion
    ip_rules = local.storage_account_firewall_allowed_ip

    virtual_network_subnet_ids = [
      module.virtualnetwork.subnets[local.subnet_names.ComputeSubnet].resource.output.id
    ]
  }

  role_assignments = {
    # Allow the current user to access the Key Vault
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }

  secrets       = merge(local.analysis_vm_password_secret, local.dc_vm_password_secret)
  secrets_value = merge(local.analysis_vm_password_value, local.dc_vm_password_value)

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  enable_telemetry = var.telemetry_enabled
}
