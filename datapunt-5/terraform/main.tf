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
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

# ============================================================
# Opdracht 1 — Netwerk Fundament
# ============================================================
module "network" {
  source              = "./modules/vnet"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

# ============================================================
# Opdracht 2 — Game Servers (VM's + Storage)
# ============================================================
module "compute" {
  source = "./modules/vm"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id      = module.network.subnet_gameserver_id
  vm_count       = var.vm_count
  admin_username = var.admin_username
  ssh_public_key = file(var.ssh_public_key_path)
  zones          = ["1", "2"]

  storage_account_name = module.storage_game.storage_account_name
  storage_account_key  = module.storage_game.storage_account_key
  fileshare_name       = module.storage_game.fileshare_name
}

# Gedeelde Azure Files voor game servers
module "storage_game" {
  source              = "./modules/storage"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  purpose             = "game"
}

# ============================================================
# Opdracht 3 — ACR + ACI Platform Services
# ============================================================
module "acr" {
  source              = "./modules/acr"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "aci" {
  source              = "./modules/aci"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_service_id   = module.network.subnet_service_id

  acr_login_server   = module.acr.acr_login_server
  acr_admin_username = module.acr.acr_admin_username
  acr_admin_password = module.acr.acr_admin_password

  matchmaking_tag = var.matchmaking_tag
  dashboard_tag   = var.dashboard_tag
  telemetry_tag   = var.telemetry_tag
}

# ============================================================
# Opdracht 4 — Monitoring & Logging
# ============================================================
module "monitoring" {
  source              = "./modules/monitoring"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  # Scope: eerste gameserver VM
  vm_id   = module.compute.vm_ids[0]
  aci_ids = module.aci.aci_ids
}

# ============================================================
# Opdracht 5 — BGP / pfSense VM
# ============================================================
module "pfsense" {
  source              = "./pfsense-azure"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_pfsense_wan_id = module.network.subnet_pfsense_wan_id
  subnet_pfsense_lan_id = module.network.subnet_pfsense_lan_id
  subnet_gameserver_id  = module.network.subnet_gameserver_id
  subnet_service_id     = module.network.subnet_service_id

  # Fix: file() hier aanroepen zodat variabele de inhoud krijgt
  ssh_public_key = file(var.ssh_public_key_path)
}
