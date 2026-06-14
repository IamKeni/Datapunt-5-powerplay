terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }
  backend "local" {
    path = "network.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
}

# ---------------------------------------------------------------
# Public IP voor pfSense WAN
# ---------------------------------------------------------------
resource "azurerm_public_ip" "pfsense_wan" {
  name                = "${var.prefix}-pfsense-wan-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ---------------------------------------------------------------
# NSG voor WAN NIC
# ---------------------------------------------------------------
resource "azurerm_network_security_group" "pfsense_wan_nsg" {
  name                = "${var.prefix}-pfsense-wan-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "IKE-500"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = var.lab_wan_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "IKE-4500"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = var.lab_wan_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ESP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Esp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.lab_wan_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.mgmt_ip_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.mgmt_ip_cidr
    destination_address_prefix = "*"
  }
}

# ---------------------------------------------------------------
# NIC WAN (PRIMARY)
# ---------------------------------------------------------------
resource "azurerm_network_interface" "pfsense_wan" {
  name                  = "${var.prefix}-pfsense-wan-nic"
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "wan"
    primary                       = true
    subnet_id                     = var.subnet_pfsense_wan_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.pfsense_wan_private_ip
    public_ip_address_id          = azurerm_public_ip.pfsense_wan.id
  }
}

resource "azurerm_network_interface_security_group_association" "pfsense_wan_assoc" {
  network_interface_id      = azurerm_network_interface.pfsense_wan.id
  network_security_group_id = azurerm_network_security_group.pfsense_wan_nsg.id
}

# ---------------------------------------------------------------
# NIC LAN (SECONDARY)
# ---------------------------------------------------------------
resource "azurerm_network_interface" "pfsense_lan" {
  name                  = "${var.prefix}-pfsense-lan-nic"
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "lan"
    primary                       = false
    subnet_id                     = var.subnet_pfsense_lan_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.pfsense_lan_private_ip
  }
}

# ---------------------------------------------------------------
# pfSense VM
# Gebruikt azurerm_linux_virtual_machine (nieuwere resource).
# Geen marketplace agreement nodig — die is al geaccepteerd.
# WAN NIC als eerste = primary interface in Azure.
# ---------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "pfsense" {
  name                            = "${var.prefix}-pfsense"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = "Standard_DS1_v2"
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.pfsense_wan.id,
    azurerm_network_interface.pfsense_lan.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "${var.prefix}-pfsense-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  plan {
    name      = "pfsense-public-pro-2511"
    publisher = "netgate"
    product   = "pfsense-plus-public-cloud-fw-vpn-router"
  }

  source_image_reference {
    publisher = "netgate"
    offer     = "pfsense-plus-public-cloud-fw-vpn-router"
    sku       = "pfsense-public-pro-2511"
    version   = "latest"
  }
}

# ---------------------------------------------------------------
# Route Table — stuurt lab-verkeer via pfSense LAN
# Gekoppeld aan gameserver én service (containers) subnet.
# ---------------------------------------------------------------
resource "azurerm_route_table" "via_pfsense" {
  name                          = "${var.prefix}-rt-via-pfsense"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false

  route {
    name                   = "to-lab"
    address_prefix         = var.lab_lan_cidr
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.pfsense_lan_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "gameserver" {
  subnet_id      = var.subnet_gameserver_id
  route_table_id = azurerm_route_table.via_pfsense.id
}

resource "azurerm_subnet_route_table_association" "service" {
  subnet_id      = var.subnet_service_id
  route_table_id = azurerm_route_table.via_pfsense.id
}
