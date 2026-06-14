variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "purpose" {
  type        = string
  description = "Korte naam voor het doel van de storage (bijv. 'game' of 'logs')"
}
