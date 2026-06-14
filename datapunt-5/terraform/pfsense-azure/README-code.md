# pfSense Azure — standalone deploy

Voer dit commando uit vanuit de `terraform/pfsense-azure/` map.

```bash
terraform init

terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102" \
  -var="ssh_public_key=$(cat ~/.ssh/azure_key.pub)" \
  -var="subnet_pfsense_wan_id=/subscriptions/c064671c-8f74-4fec-b088-b53c568245eb/resourceGroups/S1209102/providers/Microsoft.Network/virtualNetworks/powerplay-vnet/subnets/powerplay-subnet-data" \
  -var="subnet_pfsense_lan_id=/subscriptions/c064671c-8f74-4fec-b088-b53c568245eb/resourceGroups/S1209102/providers/Microsoft.Network/virtualNetworks/powerplay-vnet/subnets/powerplay-subnet-pfsense-lan" \
  -var="subnet_gameserver_id=/subscriptions/c064671c-8f74-4fec-b088-b53c568245eb/resourceGroups/S1209102/providers/Microsoft.Network/virtualNetworks/powerplay-vnet/subnets/powerplay-subnet-frontend" \
  -var="subnet_service_id=/subscriptions/c064671c-8f74-4fec-b088-b53c568245eb/resourceGroups/S1209102/providers/Microsoft.Network/virtualNetworks/powerplay-vnet/subnets/powerplay-subnet-containers" \
  -var="lab_lan_cidr=172.16.0.0/24" \
  -var="lab_wan_ip=145.44.232.230" \
  -var="mgmt_ip_cidr=145.44.232.230/32"
```

## Variabelen met defaults (hoef je niet mee te geven)

| Variabele             | Default              | Betekenis                          |
|-----------------------|----------------------|------------------------------------|
| subscription_id       | c064671c-...         | Azure subscription                 |
| location              | westeurope           | Azure regio                        |
| admin_username        | pfadmin              | Linux gebruiker op de VM           |
| pfsense_wan_private_ip| 10.0.3.4             | Privé IP WAN NIC                   |
| pfsense_lan_private_ip| 10.0.4.4             | Privé IP LAN NIC                   |
| lab_wan_ip            | 145.44.232.230       | Bron-IP voor IKE/ESP in de NSG     |
| mgmt_ip_cidr          | 145.44.232.230/32    | Bron-CIDR voor SSH/HTTPS mgmt      |
| lab_lan_cidr          | 172.16.0.0/24        | Lab LAN (route table entry)        |

## Na de deploy

De output `pfsense_public_ip` geeft het publieke WAN IP van de Azure pfSense.
Vul dit in in `ansible/host_vars/pfsense-lab.yml` bij `ipsec_remote_gateway`.
