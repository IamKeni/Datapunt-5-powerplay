output "private_ips" {
  value = [
    for nic in azurerm_network_interface.nic : nic.ip_configuration[0].private_ip_address
  ]
}

output "public_ips" {
  value = [
    for pip in azurerm_public_ip.pip : pip.ip_address
  ]
}

output "hostnames" {
  value = [
    for vm in azurerm_linux_virtual_machine.vm : vm.name
  ]
}

output "vm_ids" {
  value = azurerm_linux_virtual_machine.vm[*].id
}
