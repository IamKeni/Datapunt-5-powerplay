variable "prefix" {
  type        = string
  description = "Naam-prefix voor alle resources (bijv. 'powerplay')"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "c064671c-8f74-4fec-b088-b53c568245eb"
}

variable "location" {
  type        = string
  description = "Azure regio"
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Bestaande resource group naam"
}

# ---------------------------------------------------------------
# Subnet IDs — meegeven als -var bij standalone apply
# ---------------------------------------------------------------
variable "subnet_pfsense_wan_id" {
  type        = string
  description = "Subnet ID voor de pfSense WAN NIC"
}

variable "subnet_pfsense_lan_id" {
  type        = string
  description = "Subnet ID voor de pfSense LAN NIC"
}

variable "subnet_gameserver_id" {
  type        = string
  description = "Subnet ID van de gameserver VMs (route table koppeling)"
}

variable "subnet_service_id" {
  type        = string
  description = "Subnet ID van de ACI containers (route table koppeling)"
}

# ---------------------------------------------------------------
# Netwerk — vaste IPs voor de NICs
# Zorg dat deze IPs beschikbaar zijn in het opgegeven subnet.
# ---------------------------------------------------------------
variable "pfsense_wan_private_ip" {
  type        = string
  description = "Statisch privé IP op de WAN NIC (moet in subnet_pfsense_wan_id vallen)"
  default     = "10.0.5.4"
}

variable "pfsense_lan_private_ip" {
  type        = string
  description = "Statisch privé IP op de LAN NIC"
  default     = "10.0.4.4"
}

# ---------------------------------------------------------------
# Toegang
# ---------------------------------------------------------------
variable "admin_username" {
  type        = string
  description = "Linux gebruikersnaam op de pfSense VM"
  default     = "pfadmin"
}

variable "ssh_public_key" {
  type        = string
  description = "Inhoud van de SSH publieke sleutel (gebruik $(cat ~/.ssh/azure_key.pub))"
}

# ---------------------------------------------------------------
# Lab-kant — voor NSG en route table
# ---------------------------------------------------------------
variable "lab_wan_ip" {
  type        = string
  description = "Publiek WAN IP van het lab (bron voor IKE/ESP in de NSG)"
  default     = "145.44.232.230"
}

variable "mgmt_ip_cidr" {
  type        = string
  description = "CIDR van waaruit SSH en HTTPS management toegestaan is"
  default     = "145.44.232.230/32"
}

variable "lab_lan_cidr" {
  type        = string
  description = "LAN subnet van het lab (wordt als route in de route table gezet)"
  default     = "172.16.0.0/24"
}
