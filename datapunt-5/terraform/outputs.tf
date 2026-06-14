# ============================================================
# Opdracht 1 — Netwerk
# ============================================================
output "vnet_id" {
  value = module.network.vnet_id
}

output "subnet_gameserver_id" {
  value = module.network.subnet_gameserver_id
}

output "subnet_service_id" {
  value = module.network.subnet_service_id
}

# ============================================================
# Opdracht 2 — Game Servers
# ============================================================
output "gameserver_private_ips" {
  value = module.compute.private_ips
}

output "gameserver_hostnames" {
  value = module.compute.hostnames
}

# ============================================================
# Opdracht 3 — ACR / ACI
# ============================================================
output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "acr_admin_username" {
  value     = module.acr.acr_admin_username
  sensitive = true
}

output "matchmaking_ip" {
  value = module.aci.matchmaking_ip
}

output "dashboard_ip" {
  value = module.aci.dashboard_ip
}

output "telemetry_ip" {
  value = module.aci.telemetry_ip
}

# ============================================================
# Opdracht 4 — Monitoring
# ============================================================
output "log_storage_account_name" {
  value = module.monitoring.storage_account_name
}

# ============================================================
# Opdracht 5 — pfSense / BGP
# ============================================================
output "pfsense_public_ip" {
  value = module.pfsense.pfsense_public_ip
}

output "pfsense_private_ip" {
  value = module.pfsense.pfsense_private_ip
}
