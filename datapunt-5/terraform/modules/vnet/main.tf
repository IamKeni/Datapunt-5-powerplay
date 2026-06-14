resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# ---------------------------------------------------------
# 10.0.1.0/24 — subnet-frontend (game VM's)
# ---------------------------------------------------------
resource "azurerm_subnet" "frontend" {
  name                 = "${var.prefix}-subnet-frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ---------------------------------------------------------
# 10.0.2.0/24 — subnet-containers (ACI)
# ---------------------------------------------------------
resource "azurerm_subnet" "containers" {
  name                 = "${var.prefix}-subnet-containers"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "aciDelegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# ---------------------------------------------------------
# 10.0.3.0/24 — subnet-data (Private Endpoints / overig)
# ---------------------------------------------------------
resource "azurerm_subnet" "data" {
  name                 = "${var.prefix}-subnet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# ---------------------------------------------------------
# 10.0.4.0/24 — subnet-pfsense-lan (pfSense LAN interface)
# ---------------------------------------------------------
resource "azurerm_subnet" "pfsense_lan" {
  name                 = "${var.prefix}-subnet-pfsense-lan"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# ---------------------------------------------------------
# 10.0.5.0/24 — subnet-pfsense-wan (pfSense WAN interface)
# ---------------------------------------------------------
resource "azurerm_subnet" "pfsense_wan" {
  name                 = "${var.prefix}-subnet-pfsense-wan"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/24"]
}

# ---------------------------------------------------------
# NSG voor subnet-frontend
# ---------------------------------------------------------
resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "${var.prefix}-frontend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-UDP-GameTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "7777"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-API"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Management"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "frontend_assoc" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}

# ---------------------------------------------------------
# NSG voor subnet-containers
# ---------------------------------------------------------
resource "azurerm_network_security_group" "containers_nsg" {
  name                = "${var.prefix}-containers-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP-Internal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3000", "3001", "8080"]
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "containers_assoc" {
  subnet_id                 = azurerm_subnet.containers.id
  network_security_group_id = azurerm_network_security_group.containers_nsg.id
}
