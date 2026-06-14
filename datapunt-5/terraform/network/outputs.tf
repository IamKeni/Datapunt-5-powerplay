output "resource_group_name" {
  value = var.resource_group_name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "subnet_frontend_id" {
  value = module.vnet.subnet_frontend_id
}

output "subnet_gameserver_id" {
  description = "Alias voor subnet_frontend_id (gameserver VMs)"
  value       = module.vnet.subnet_gameserver_id
}

output "subnet_containers_id" {
  value = module.vnet.subnet_containers_id
}

output "subnet_service_id" {
  description = "Alias voor subnet_containers_id (ACI)"
  value       = module.vnet.subnet_service_id
}

output "subnet_data_id" {
  value = module.vnet.subnet_data_id
}

output "subnet_pfsense_lan_id" {
  value = module.vnet.subnet_pfsense_lan_id
}

output "subnet_pfsense_wan_id" {
  description = "WAN subnet voor pfSense NIC"
  value       = module.vnet.subnet_pfsense_wan_id
}
