variable "subscription_id_bootstrap" {
  type = string
}

variable "managed_id" {
  default = ""
  type    = string

}

variable "location" {
  default = "canadacentral"
  type    = string
}

variable "telemetry_enabled" {
  default = false
  type    = bool
}

