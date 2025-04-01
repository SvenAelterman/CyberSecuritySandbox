variable "deploy_firewall" {
  type        = bool
  description = "Flag to deploy Azure Firewall."
  default     = false
}

variable "deploy_bastion" {
  type        = bool
  description = "Flag to deploy Azure Bastion."
  default     = false
}

variable "deploy_natgw" {
  type        = bool
  description = "Flag to deploy NAT Gateway."
  default     = false
}

variable "deploy_dc" {
  type        = bool
  description = "Flag to deploy Domain Controller."
  default     = false
}

variable "deploy_windows_vm" {
  type        = bool
  description = "Flag to deploy Windows VM."
  default     = false
}
