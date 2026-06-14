variable "subscription_id" {
  type    = string
  default = "c064671c-8f74-4fec-b088-b53c568245eb"
}

variable "prefix" {
  type        = string
  description = "Naam-prefix voor alle resources"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Bestaande resource group naam"
}

variable "subnet_service_id" {
  type        = string
  description = "Subnet ID van het Service subnet (output van Opdracht 1)"
}

variable "acr_login_server" {
  type        = string
  description = "Login server URL van de ACR (output van Opdracht 3a)"
}

variable "acr_admin_username" {
  type        = string
  description = "Admin gebruikersnaam van de ACR"
}

variable "acr_admin_password" {
  type        = string
  sensitive   = true
  description = "Admin wachtwoord van de ACR"
}

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
