# module "dc_nic" {
#   source = "Azure/avm-res-network-networkinterface/azurerm"

#   location            = var.location
#   name                = "soc-dc-vm-nic-01"
#   resource_group_name = azurerm_resource_group.dc_rg.name

#   enable_telemetry = var.telemetry_enabled

#   ip_configurations = {
#     "ipconfig1" = {
#       name                          = "ipconfig1"
#       subnet_id                     = module.avm-res-network-virtualnetwork.subnets["DomainControllerSubnet"].resource.output.id
#       private_ip_address_allocation = "Static"

#       // TODO: Use CIDR functions
#       private_ip_address = "10.0.1.4"
#     }
#   }
# }

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
  sku_size                           = "Standard_D2as_v5"
  // TODO: Is this really required?
  zone = 1

  encryption_at_host_enabled = false

  // TODO: Re-enable?
  #   generated_secrets_key_vault_secret_config = {
  #     key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  #   }

  # custom_data got injected in the vm at c:\AzureData\CustomData.bin
  #   custom_data = base64encode(<<-CD
  #   # Enable WinRM HTTPS listener
  #   Enable-PSRemoting -Force

  #   Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -like 'Transport=HTTP*' | Remove-Item -Recurse
  #   $certificate = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "CN=${module.naming.virtual_machine.name_unique}"}
  #   New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -Port ${local.winrms_port} -CertificateThumbprint $certificate.thumbprint -Force

  #   # Allow HTTPS traffic in the Windows firewall
  #   New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort ${local.winrms_port} -Protocol TCP -Action Allow -Verbose

  #   # Set HTTPS listener to be the default listener
  #   winrm set winrm/config/service/Auth '@{Certificate="true"}'
  #   winrm set winrm/config/service '@{AllowUnencrypted="false"}'

  #   # Restart WinRM service
  #   Restart-Service WinRM -Force
  #   # Display for logs
  #   WinRM e winrm/config/listener
  #   CD
  #   )

  extensions = {
    create_ad_forest = {
      name                       = "create_ad_forest"
      publisher                  = "Microsoft.PowerShell"
      type                       = "DSC"
      type_handler_version       = "2.80"
      auto_upgrade_minor_version = true

      protectedSettings = jsonencode({
        configurationArguments = {
          adminCreds = {
            userName = "srvadmin"
            Password = "Password1234!"
          }
        }
      })
      settings = jsonencode(
        {
          #   ModulesUrl            = "https://github.com/SvenAelterman/CyberSecuritySandbox/raw/refs/heads/svaelter/domain-controller/support/CreateADPDC.zip"
          #   ConfigurationFunction = "CreateADPDC.ps1\\CreateADPDC"
          #   properties = {
          #     domainName = "intra.sandbox.com"
          #     adminCreds = {
          #       userName = "srvadmin"
          #       Password = "PrivateSettingsRef:AdminPassword"
          #     }
          #   }
          configuration = {
            url      = "https://github.com/SvenAelterman/CyberSecuritySandbox/raw/refs/heads/svaelter/domain-controller/support/CreateADPDC.zip"
            script   = "CreateADPDC.ps1"
            function = "CreateADPDC"
          }
          configurationArguments = {
            domainName = "intra.sandbox.com"
            # adminCreds = {
            #   userName = "srvadmin"
            #   Password = "PrivateSettingsRef:AdminPassword"
            # }
          }
        }
      )
    }
    # install_winrms = {
    #   name                        = "install_winrms"
    #   failure_suppression_enabled = false
    #   publisher                   = "Microsoft.Compute"
    #   type                        = "CustomScriptExtension"
    #   type_handler_version        = "1.10"

    #   settings = jsonencode(
    #     {
    #       commandToExecute = "copy c:\\AzureData\\CustomData.bin c:\\AzureData\\winrms.ps1 && powershell.exe -ExecutionPolicy Unrestricted -File c:\\AzureData\\winrms.ps1 > C:\\AzureData\\winrms.log"
    #     }
    #   )

    # }
    # openssh_windows = {
    #   name                        = "WindowsOpenSSH"
    #   failure_suppression_enabled = true
    #   publisher                   = "Microsoft.Azure.OpenSSH"
    #   type                        = "WindowsOpenSSH"
    #   type_handler_version        = "3.0"
    # }
    # keyvault_extension = {
    #   name                       = "KVVMExtension"
    #   publisher                  = "Microsoft.Azure.KeyVault"
    #   type                       = lower(local.os_type) == "windows" ? "KeyVaultForWindows" : "KeyVaultForLinux"
    #   type_handler_version       = lower(local.os_type) == "windows" ? "3.0" : "2.0"
    #   auto_upgrade_minor_version = true
    #   settings = jsonencode(
    #     {
    #       secretsManagementSettings = {
    #         pollingIntervalInS = "60"                                              #"3600"
    #         linkOnRenewal      = lower(local.os_type) == "windows" ? false : false # always false on Linux.
    #         requireInitialSync = true                                              # requires user msi https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-linux#extension-dependency-ordering
    #         observedCertificates = [
    #           {
    #             url                      = azurerm_key_vault_certificate.self_signed_winrm.versionless_secret_id
    #             certificateStoreName     = lower(local.os_type) == "windows" ? "MY" : null
    #             certificateStoreLocation = lower(local.os_type) == "windows" ? "LocalMachine" : "/var/lib/waagent/Microsoft.Azure.KeyVault"
    #           }
    #         ]
    #       }
    #       authenticationSettings = {
    #         msiEndpoint = "http://169.254.169.254/metadata/identity/oauth2/token"
    #         msiClientId = azurerm_user_assigned_identity.this.client_id
    #       }
    #     }
    #   )
    #   # Troubleshooting logs - https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-windows?tabs=version3#review-logs-and-configuration
    #   # more 
    # }
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    // TODO: Consider using smalldisk image
    sku     = "2022-datacenter-g2"
    version = "latest"
  }

  #   managed_identities = {
  #     user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  #   }

  network_interfaces = {
    network_interface_1 = {
      name = "soc-dc-vm-nic-01"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = module.avm-res-network-virtualnetwork.subnets["DomainControllerSubnet"].resource.output.id
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.0.1.4"
        }
      }
    }
  }
}

// TODO: Update VNet's DNS server IP to DC IP
