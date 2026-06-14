terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }
  backend "local" {
    path = "aci.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

module "aci" {
  source              = "../modules/aci"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_service_id   = var.subnet_service_id

  acr_login_server   = var.acr_login_server
  acr_admin_username = var.acr_admin_username
  acr_admin_password = var.acr_admin_password

  matchmaking_tag = var.matchmaking_tag
  dashboard_tag   = var.dashboard_tag
  telemetry_tag   = var.telemetry_tag
}
