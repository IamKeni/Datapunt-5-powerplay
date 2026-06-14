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
