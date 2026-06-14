output "matchmaking_ip" {
  value = azurerm_container_group.matchmaking.ip_address
}

output "dashboard_ip" {
  value = azurerm_container_group.dashboard.ip_address
}

output "telemetry_ip" {
  value = azurerm_container_group.telemetry.ip_address
}

output "aci_ids" {
  value = [
    azurerm_container_group.matchmaking.id,
    azurerm_container_group.dashboard.id,
    azurerm_container_group.telemetry.id,
  ]
}
