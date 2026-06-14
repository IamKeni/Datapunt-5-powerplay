output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_frontend_id" {
  value = azurerm_subnet.frontend.id
}

output "subnet_containers_id" {
  value = azurerm_subnet.containers.id
}

output "subnet_data_id" {
  value = azurerm_subnet.data.id
}

output "subnet_pfsense_lan_id" {
  value = azurerm_subnet.pfsense_lan.id
}

# WAN subnet voor de pfSense WAN NIC
output "subnet_pfsense_wan_id" {
  value = azurerm_subnet.pfsense_wan.id
}

# Aliases die root main.tf verwacht
output "subnet_gameserver_id" {
  value = azurerm_subnet.frontend.id
}

output "subnet_service_id" {
  value = azurerm_subnet.containers.id
}

output "subnet_pfsense_id" {
  value = azurerm_subnet.pfsense_wan.id
}
