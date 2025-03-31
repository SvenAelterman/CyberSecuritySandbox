locals {
  subscription_id = var.subscription_id_soc_sandbox
  location        = lower(var.location)

  subnet_names = {
    AzureFirewallSubnet           = "AzureFirewallSubnet"
    AzureFirewallManagementSubnet = "AzureFirewallManagementSubnet"
    AzureBastionSubnet            = "AzureBastionSubnet"
    DomainControllerSubnet        = "DomainControllerSubnet"
    ComputeSubnet                 = "ComputeSubnet"
  }

  instance_formatted = format("%02d", var.instance)
  naming_structure   = replace(replace(replace(replace(var.naming_convention, "{workloadName}", var.workload_name), "{environment}", var.environment), "{region}", local.short_locations[var.location]), "{instance}", local.instance_formatted)
}

locals {
  short_locations = {
    canadacentral = "cnc"
    eastus        = "eus"
    westus        = "wus"
  }
}
