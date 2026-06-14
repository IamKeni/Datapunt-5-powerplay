resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = "${var.prefix}-gameserver-pip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  # Elke VM in zijn eigen zone
  zones = [var.zones[count.index]]
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.prefix}-gameserver-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "${var.prefix}-gameserver-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Standard_DS2_v2: 2 vCPU / 7 GB RAM — geschikt voor game servers
  size = "Standard_DS1_v2"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Hoge beschikbaarheid via Availability Zones
  zone = var.zones[count.index]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # FIX: path.module verwijst nu correct naar de cloudinit map
  # naast de modules/ map (één niveau omhoog)
  custom_data = base64encode(templatefile("${path.module}/../../cloudinit/gameserver.yaml", {
    admin_username       = var.admin_username
    storage_account_name = var.storage_account_name
    storage_account_key  = var.storage_account_key
    fileshare_name       = var.fileshare_name
  }))
}
