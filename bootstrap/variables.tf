variable "subscription_id_bootstrap" {
  type = string
}

variable "managed_id" {
  default     = ""
  type        = string
  description = "Managed identity that will be given access to the Terraform state file."
}

variable "location" {
  default = "canadacentral"
  type    = string
}

variable "telemetry_enabled" {
  default = false
  type    = bool
}
