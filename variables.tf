variable "subscription_id_soc_sandbox" {
  type = string
}

variable "vnet_address_space" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition     = tonumber(split("/", var.vnet_address_space)[1]) <= 23
    error_message = "The provided address space '${var.vnet_address_space}' must be at least /23."
  }
  validation {
    condition     = can(cidrhost(var.vnet_address_space, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}
variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "naming_convention" {
  type        = string
  description = "The naming convention to be used for all resources in this deployment."
  default     = "{workloadName}-{environment}-{resourceType}-{region}-{instance}"
}

locals {
  // Calculate the maximum length of the workload name based on other inputs
  // The restriction is the maximum length of the Key Vault name (24 characters)
  workload_name_max_length = 24 - length(var.environment) - length("-") - length("-${local.short_locations[var.location]}") - length("-00") - length("-kv")
}

variable "workload_name" {
  type        = string
  description = "The name of the workload to be deployed."
  validation {
    condition     = length(var.workload_name) <= local.workload_name_max_length
    error_message = "The maximum length is ${local.workload_name_max_length}, which is based on some other inputs. '${var.workload_name}' is ${length(var.workload_name)} characters long."
  }
}

variable "environment" {
  type        = string
  description = "The environment name for the resources."
  default     = "demo"
}

variable "instance" {
  type        = number
  description = "The instance number for the deployment."
  default     = 1
}

variable "telemetry_enabled" {
  default = false
  type    = bool
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "storage_account_name_prefix" {
  type        = list(any)
  description = "The prefix for the storage account name. If not provided, it will default to the workload name and environment."
  default     = []
}

variable "storage_account_name_suffix" {
  default     = []
  type        = list(any)
  description = "The suffix(es) for the storage account name. If not provided, it will default to the region and instance number."
}
