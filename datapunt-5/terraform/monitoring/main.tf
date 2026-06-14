terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
  backend "local" {
    path = "monitoring.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

module "monitoring" {
  source              = "../modules/monitoring"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  vm_id               = var.vm_id
  aci_ids             = var.aci_ids
}
