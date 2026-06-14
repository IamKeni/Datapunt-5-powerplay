terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }
  backend "local" {
    path = "compute.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Gedeelde Azure Files voor de game servers
module "storage_game" {
  source              = "../modules/storage"
  prefix              = var.prefix
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  purpose             = "game"
}

module "gameservers" {
  source = "../modules/vm"

  prefix              = var.prefix
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  subnet_id      = var.subnet_gameserver_id
  vm_count       = var.vm_count
  admin_username = var.admin_username
  ssh_public_key = file(var.ssh_public_key_path)
  zones          = ["1", "2"]

  storage_account_name = module.storage_game.storage_account_name
  storage_account_key  = module.storage_game.storage_account_key
  fileshare_name       = module.storage_game.fileshare_name
}
