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

variable "vm_id" {
  type        = string
  description = "Resource ID van de te monitoren gameserver VM (output van Opdracht 2)"
}

variable "aci_ids" {
  type        = list(string)
  description = "Lijst met ACI container group IDs (output van Opdracht 3)"
}
