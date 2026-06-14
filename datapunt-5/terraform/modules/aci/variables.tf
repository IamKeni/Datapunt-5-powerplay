variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_service_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "acr_admin_username" {
  type = string
}

variable "acr_admin_password" {
  type      = string
  sensitive = true
}

variable "matchmaking_tag" {
  type = string
}

variable "dashboard_tag" {
  type = string
}

variable "telemetry_tag" {
  type = string
}
