variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_key" {
  type      = string
  sensitive = true
}

variable "fileshare_name" {
  type = string
}
