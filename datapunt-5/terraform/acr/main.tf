terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }
  backend "local" {
    path = "acr.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

module "acr" {
  source              = "../modules/acr"
  prefix              = var.prefix
  resource_group_name = var.resource_group_name
  location            = var.location
}
