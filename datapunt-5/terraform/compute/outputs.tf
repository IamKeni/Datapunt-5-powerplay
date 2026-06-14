output "gameserver_private_ips" {
  value = module.gameservers.private_ips
}

output "gameserver_public_ips" {
  value = module.gameservers.public_ips
}

output "gameserver_hostnames" {
  value = module.gameservers.hostnames
}

output "vm_ids" {
  value = module.gameservers.vm_ids
}

output "storage_account_name" {
  value = module.storage_game.storage_account_name
}
