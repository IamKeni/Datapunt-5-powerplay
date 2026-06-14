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

variable "subnet_gameserver_id" {
  type        = string
  description = "Subnet ID van het Game Server subnet (output van Opdracht 1)"
}

variable "admin_username" {
  type    = string
  default = "gameserveradmin"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Pad naar je SSH public key (bijv. ~/.ssh/id_rsa.pub)"
}

variable "vm_count" {
  type    = number
  default = 2
}
