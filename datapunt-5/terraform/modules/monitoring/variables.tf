variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_id" {
  type        = string
  description = "Resource ID van de te monitoren gameserver VM"
}

variable "aci_ids" {
  type        = list(string)
  description = "Lijst met ACI container group IDs om te monitoren"
}
