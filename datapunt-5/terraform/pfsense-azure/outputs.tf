output "pfsense_public_ip" {
  description = "Publiek WAN IP van de Azure pfSense"
  value       = azurerm_public_ip.pfsense_wan.ip_address
}

output "pfsense_wan_private_ip" {
  description = "Privé WAN IP van de Azure pfSense"
  value       = var.pfsense_wan_private_ip
}

# Alias die root outputs.tf verwacht
output "pfsense_private_ip" {
  description = "Alias voor pfsense_wan_private_ip (compatibiliteit root outputs)"
  value       = var.pfsense_wan_private_ip
}

output "pfsense_lan_private_ip" {
  description = "Privé LAN IP van de Azure pfSense"
  value       = var.pfsense_lan_private_ip
}

output "pfsense_vm_id" {
  description = "Resource ID van de pfSense VM"
  value       = azurerm_linux_virtual_machine.pfsense.id
}

output "route_table_id" {
  description = "Route Table ID gekoppeld aan gameserver en service subnetten"
  value       = azurerm_route_table.via_pfsense.id
}
