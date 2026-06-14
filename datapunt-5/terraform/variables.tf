variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "c064671c-8f74-4fec-b088-b53c568245eb"
}

variable "prefix" {
  type        = string
  description = "Naam-prefix voor alle resources (bijv. 'powerplay')"
}

variable "location" {
  type        = string
  description = "Azure regio"
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Bestaande resource group naam (bijv . 'S1209102')"
}

# --- Compute ---
variable "admin_username" {
  type    = string
  default = "gameserveradmin"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Pad naar de SSH publieke sleutel (bijv. ~/.ssh/id_rsa.pub)"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_count" {
  type    = number
  default = 2
}

# --- ACI image tags ---
variable "matchmaking_tag" {
  type    = string
  default = "v1"
}

variable "dashboard_tag" {
  type    = string
  default = "v1"
}

variable "telemetry_tag" {
  type    = string
  default = "v1"
}
