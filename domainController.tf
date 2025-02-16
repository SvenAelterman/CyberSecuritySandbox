module "dc_vm" {
  source = "Azure/avm-res-compute-virtualmachine/azurerm"

  // TODO: Use Key Vault
  admin_password = "Password1234!"
  #admin_credential_key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  admin_username = "srvadmin"

  enable_telemetry                   = var.telemetry_enabled
  generate_admin_password_or_ssh_key = false
  location                           = var.location
  name                               = "soc-dc-vm-01"
  resource_group_name                = azurerm_resource_group.dc_rg.name
  os_type                            = "Windows"
  zone                               = null
  // Must use a SKU with a local temp disk because the data disk is expected to be "Disk2" (// TODO: confirm)
  sku_size = "Standard_D2ads_v5"

  encryption_at_host_enabled = false

  // TODO: Re-enable?
  #   generated_secrets_key_vault_secret_config = {
  #     key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  #   }

  extensions = {
    create_ad_forest = { // TODO: Consider using Machine Configuration instead?
      name                       = "create_ad_forest"
      publisher                  = "Microsoft.PowerShell"
      type                       = "DSC"
      type_handler_version       = "2.83"
      auto_upgrade_minor_version = false // Not supported anyway

      protected_settings = jsonencode({
        configurationArguments = {
          AdminCreds = {
            UserName = "srvadmin"
            Password = "Password1234!"
          }
        }
      })
      settings = jsonencode(
        {
          wmfVersion = "latest"
          configuration = {
            url      = "https://github.com/Azure/azure-quickstart-templates/raw/refs/heads/master/application-workloads/active-directory/active-directory-new-domain/DSC/CreateADPDC.zip"
            script   = "CreateADPDC.ps1"
            function = "CreateADPDC"
          }
          configurationArguments = {
            DomainName = "intra.sandbox.com"
          }
        }
      )
    }
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    // TODO: Consider using smalldisk image
    sku     = "2022-datacenter-g2"
    version = "latest"
  }

  managed_identities = {
    system_assigned = false
  }

  // The ADDS provisioning requires a second disk
  data_disk_managed_disks = {
    datadisk0 = {
      caching              = "None"
      lun                  = 0
      name                 = "soc-dc-vm-01_datadisk0"
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 10
    }
  }

  // TODO: Check storage profile: use standard SSD LRS

  network_interfaces = {
    network_interface_1 = {
      name = "soc-dc-vm-nic-01"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = module.virtualnetwork.subnets[local.subnet_names.DomainControllerSubnet].resource.output.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.virtualnetwork.subnets[local.subnet_names.DomainControllerSubnet].resource.output.properties.addressPrefixes[0], 4)
        }
      }
    }
  }

  license_type = "Windows_Server"
}

// Update VNet's DNS server IP to DC IP
// Note: setting DNS IPs here precludes setting them in the VNet module
resource "azurerm_virtual_network_dns_servers" "vnet_dns" {
  virtual_network_id = module.virtualnetwork.resource_id
  dns_servers        = [module.dc_vm.network_interfaces.network_interface_1.private_ip_address]

  depends_on = [module.dc_vm]
}

# output "ipconfig" {
#   value = module.dc_vm.network_interfaces.network_interface_1
# }
