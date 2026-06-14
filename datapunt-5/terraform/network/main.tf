terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }
  backend "local" {
    path = "network.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

module "vnet" {
  source              = "../modules/vnet"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}
