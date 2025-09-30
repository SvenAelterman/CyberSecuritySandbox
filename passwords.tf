# Random password generation for VM accounts using HashiCorp modules
# This file generates strong, unique passwords for VM accounts and stores them in Azure Key Vault

# Generate random password for Domain Controller admin account
resource "random_password" "dc_admin_password" {
  count = var.deploy_dc ? 1 : 0

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
  # Exclude characters that can cause issues in PowerShell/Windows
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?"

  # Ensure we have at least one of each character type
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

# Generate random password for Analysis VM admin account
resource "random_password" "analysis_vm_admin_password" {
  count = var.deploy_windows_vm ? 1 : 0

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
  # Exclude characters that can cause issues in PowerShell/Windows
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?"

  # Ensure we have at least one of each character type
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}
