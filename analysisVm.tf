module "analysis_win_vm" {
  count = var.deploy_windows_vm ? 1 : 0

  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.18.1"

  // TODO: Use Key Vault
  admin_password = "Password1234!"
  #admin_credential_key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  admin_username = "srvadmin"

  generate_admin_password_or_ssh_key = false
  location                           = var.location
  name                               = "soc-vm-01"
  resource_group_name                = module.analysis_rg.name
  os_type                            = "Windows"
  sku_size                           = "Standard_D2as_v5"
  zone                               = null

  encryption_at_host_enabled = false

  license_type = "Windows_Client"

  // TODO: Re-enable?
  #   generated_secrets_key_vault_secret_config = {
  #     key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  #   }

  extensions = {
    domain_join = {
      name                    = "domain_join"
      publisher               = "Microsoft.Compute"
      type                    = "JsonADDomainExtension"
      type_handler_version    = "1.3"
      autoUpgradeMinorVersion = true

      settings = jsonencode({
        Name    = "intra.sandbox.com"
        User    = "INTRA\\srvadmin"
        Restart = "true"
        Options = "3"
      })

      protected_settings = jsonencode({
        Password = "Password1234!"
      })
    }
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-ent"
    version   = "latest"
  }

  managed_identities = {
    system_assigned = false
  }

  // TODO: Check storage profile: use standard SSD LRS

  network_interfaces = {
    network_interface_1 = {
      name = "soc-vm-nic-01"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = module.virtualnetwork.subnets[local.subnet_names.ComputeSubnet].resource.output.id
          private_ip_address_allocation = "Dynamic"
        }
      }
    }
  }

  enable_telemetry = var.telemetry_enabled

  depends_on = [azurerm_virtual_network_dns_servers.vnet_dns]
}
