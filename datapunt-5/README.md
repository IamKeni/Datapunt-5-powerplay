# Installatiehandleiding - Powerplay Infrastructuur

Deze map bevat het volledige Terraform- en Ansible-project voor de Powerplay-infrastructuur op Azure. De infrastructuur is modulair opgezet en wordt stap voor stap uitgerold in vijf opdrachten.

---

## Deployvolgorde

De modules hebben onderlinge afhankelijkheden. Volg altijd deze volgorde:

```
1. terraform/network/       → VNet + subnets aanmaken
        ↓ geeft subnet IDs door aan:
2. terraform/compute/       → gameserver VM's
3. terraform/acr/           → container registry (kan altijd, geen subnet nodig)
4. terraform/aci/           → containers (heeft subnet + ACR outputs nodig)
5. terraform/pfsense-azure/ → pfSense VM (heeft subnet IDs nodig)
        ↓ geeft VM IDs door aan:
6. terraform/monitoring/    → monitoring (heeft vm_id + aci_ids nodig)
```

---

## Opdracht 1 - Netwerk Fundament

### Wat doet deze code?
- Maakt een **Virtual Network** aan (10.0.0.0/16)
- Maakt subnetten aan voor gameservers, containers, pfSense WAN en pfSense LAN
- Maakt een **Network Security Group** met regels voor UDP 7777 en SSH 22
- Alles modulair via `modules/vnet`

### Deployen
```bash
cd terraform/network
terraform init
terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102"
```

### Outputs (nodig voor volgende opdrachten)
- `subnet_gameserver_id`
- `subnet_service_id`
- `subnet_pfsense_wan_id`
- `subnet_pfsense_lan_id`

---

## Opdracht 2 - Compute Layer

### Wat doet deze code?
- Maakt **twee Linux VM's** aan in verschillende Availability Zones
- Maakt een **Azure Files share** aan
- Mount de share automatisch via **CloudInit**
- Gebruikt module: `modules/vm`

### Deployen
```bash
cd terraform/compute
terraform init
terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102" \
  -var="subnet_gameserver_id=<id-uit-opdracht-1>" \
  -var="ssh_public_key_path=~/.ssh/azure_key.pub"
```

### Outputs
- `gameserver_private_ips`
- `gameserver_hostnames`

---

## Opdracht 3 - Container Platform

### Wat doet deze code?
- Maakt een **Azure Container Registry** aan
- Bouwt en pusht drie Docker-images: Matchmaking API, Player Dashboard, Telemetry Collector
- Deployt drie **Azure Container Instances** in het private subnet
- Gebruikt modules: `modules/acr` en `modules/aci`

### Stap 1 - ACR deployen
```bash
cd terraform/acr
terraform init
terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102"
```

### Stap 2 - Docker images bouwen en pushen
```bash
git clone https://gitlab.windesheim.nl/org.hbo-ict/cse/cloud-automation/v25/c2-dp5-applicaties.git
cd c2-dp5-applicaties

az acr login --name powerplayregistry

docker build -t powerplayregistry.azurecr.io/matchmaking-api:v1 ./matchmaking-api
docker push powerplayregistry.azurecr.io/matchmaking-api:v1

docker build -t powerplayregistry.azurecr.io/player-dashboard:v1 ./player-dashboard
docker push powerplayregistry.azurecr.io/player-dashboard:v1

docker build -t powerplayregistry.azurecr.io/telemetry-collector:v1 ./telemetry-collector
docker push powerplayregistry.azurecr.io/telemetry-collector:v1
```

### Stap 3 - ACI deployen
```bash
cd terraform/aci
terraform init
terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102" \
  -var="subnet_service_id=<id-uit-opdracht-1>" \
  -var="acr_login_server=powerplayregistry.azurecr.io" \
  -var="matchmaking_tag=v1" \
  -var="dashboard_tag=v1" \
  -var="telemetry_tag=v1"
```

---

## Opdracht 4 - Monitoring

### Wat doet deze code?
- Configureert **Azure Monitor Alerts** voor gameserver VM's en ACI containers
- Koppelt **Metrics + Log Analytics**
- Gebruikt module: `modules/monitoring`

### Deployen
```bash
cd terraform/monitoring
terraform init
terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102" \
  -var="vm_id=<vm_id-uit-opdracht-2>" \
  -var='aci_ids=["/subscriptions/.../matchmaking", "/subscriptions/.../dashboard", "/subscriptions/.../telemetry"]'
```

---

## Opdracht 5 - pfSense / BGP Router

### Wat doet deze code?

**Terraform (`terraform/pfsense-azure/`)** deployt een pfSense Plus firewall in Azure met:
- Statisch publiek IP op de WAN interface
- WAN NIC + LAN NIC (voor routing naar Azure subnetten)
- NSG met regels voor IKEv2 (UDP 500/4500), ESP en SSH/HTTPS beheer
- Route table die lab-verkeer (`172.16.0.0/24`) via de pfSense LAN stuurt

**Ansible (`ansible/`)** configureert automatisch op beide pfSense systemen (Azure én Lab):
- IPsec Phase 1 en Phase 2 in VTI modus
- FRR pakket installeren
- BGP neighbor, AS nummer, router-id en te adverteren netwerk
- BFD activeren voor snelle failover detectie

---

### Stap 1 - Terraform: pfSense VM deployen

Marketplace-image accepteren (eenmalig per subscription):
```bash
az vm image terms accept \
  --publisher netgate \
  --offer pfsense-plus-public-cloud-fw-vpn-router \
  --plan pfsense-public-pro-2511
```

Deployen:
```bash
cd terraform/pfsense-azure
terraform init
terraform apply \
  -var="prefix=powerplay" \
  -var="resource_group_name=S1209102" \
  -var="ssh_public_key=$(cat ~/.ssh/azure_key.pub)" \
  -var="subnet_pfsense_wan_id=<id-uit-opdracht-1>" \
  -var="subnet_pfsense_lan_id=<id-uit-opdracht-1>" \
  -var="subnet_gameserver_id=<id-uit-opdracht-1>" \
  -var="subnet_service_id=<id-uit-opdracht-1>" \
  -var="lab_wan_ip=145.44.232.230" \
  -var="mgmt_ip_cidr=145.44.232.230/32" \
  -var="lab_lan_cidr=172.16.0.0/24"
```

Variabelen met defaults:

| Variabele | Default | Betekenis |
|-----------|---------|-----------|
| `location` | `westeurope` | Azure regio |
| `admin_username` | `pfadmin` | Linux gebruiker op de VM |
| `pfsense_wan_private_ip` | `10.0.5.4` | Privé IP WAN NIC |
| `pfsense_lan_private_ip` | `10.0.4.4` | Privé IP LAN NIC |
| `lab_wan_ip` | `145.44.232.230` | Bron-IP voor IKE/ESP in de NSG |
| `mgmt_ip_cidr` | `145.44.232.230/32` | Bron-CIDR voor SSH/HTTPS beheer |
| `lab_lan_cidr` | `172.16.0.0/24` | Lab LAN (route table entry) |

Publiek IP ophalen (nodig voor Ansible):
```bash
terraform output pfsense_public_ip
```

---

### Stap 2 - Handmatige configuratie pfSense (eenmalig)

De pfSense GUI is alleen bereikbaar via localhost. Gebruik een SSH tunnel:
```bash
ssh -i ~/.ssh/azure_key -L 8443:127.0.0.1:443 pfadmin@<pfsense_public_ip> -N
```

Open daarna in je browser: `https://localhost:8443`

**2a - Admin gebruiker aanmaken** via de pfSense GUI.

**2b - REST API installeren** via Diagnostics → Command Prompt:
```bash
pkg-static add https://github.com/jaredhendrickson13/pfsense-api/releases/latest/download/pfSense-2.8.1-pkg-RESTAPI.pkg
```

**2c - API sleutel aanmaken** via System → REST API → Keys. Kopieer de sleutel naar `ansible/host_vars/pfsense-azure.yml`.

**2d - FRR instellen via GUI** op beide pfSense systemen (Services → FRR):

| Instelling | Azure pfSense | Lab pfSense |
|------------|---------------|-------------|
| Enable FRR | ✅ Aan | ✅ Aan |
| Default Router ID | `10.0.4.4` | `172.16.0.1` |
| Master Password | waarde uit `vars.yml` | idem |
| Enable BGP Routing | ✅ Aan | ✅ Aan |
| Local AS | `65001` | `65002` |
| Enable BFD Daemon | ✅ Aan | ✅ Aan |

---

### Stap 3 - Ansible: IPsec en BGP configureren

Variabelen instellen in `ansible/group_vars/all/vars.yml`:
```yaml
ipsec_psk:           "JouwSterkWachtwoord"
frr_master_password: "JouwFRRWachtwoord"
```

Variabelen instellen in `ansible/host_vars/pfsense-azure.yml`:
```yaml
pfsense_host:         "https://127.0.0.1:8443"
pfsense_api_token:    "jouw-azure-api-token"
ipsec_remote_gateway: "145.44.232.230"
ipsec_phase1_ikeid:   1
ipsec_vti_local:      "10.10.0.1"
ipsec_vti_remote:     "10.10.0.2"
bgp_local_as:         "65001"
bgp_router_id:        "10.0.4.4"
bgp_peer_ip:          "10.10.0.2"
bgp_peer_as:          "65002"
bgp_advertise_network: "10.0.0.0/16"
```

Variabelen instellen in `ansible/host_vars/pfsense-lab.yml`:
```yaml
pfsense_host:         "https://145.44.232.230"
pfsense_api_token:    "jouw-lab-api-token"
ipsec_remote_gateway: "52.157.71.154"
ipsec_phase1_ikeid:   1
ipsec_vti_local:      "10.10.0.2"
ipsec_vti_remote:     "10.10.0.1"
bgp_local_as:         "65002"
bgp_router_id:        "172.16.0.1"
bgp_peer_ip:          "10.10.0.1"
bgp_peer_as:          "65001"
bgp_advertise_network: "172.16.0.0/24"
```

Playbook uitvoeren:
```bash
cd ansible/
ansible-playbook -i inventory/hosts.ini site.yml
```

BGP status controleren:
```bash
ssh -i ~/.ssh/azure_key pfadmin@<pfsense_public_ip>
sudo vtysh -c "show bgp summary"
sudo vtysh -c "show ip route"
sudo vtysh -c "show bfd peers"
```

### Is de Ansible code idempotent?

| Onderdeel | Idempotent? | Toelichting |
|-----------|-------------|-------------|
| IPsec Phase 1 | ✅ Ja | Bestaande `ikeid` wordt hergebruikt |
| IPsec Phase 2 | ✅ Ja | Duplicate geeft `409` terug, wordt geaccepteerd |
| FRR installatie | ✅ Ja | Wordt overgeslagen als al aanwezig |
| BGP via vtysh | ⚠️ Deels | Neighbor wordt opnieuw aangemaakt als die al bestaat - geeft waarschuwing maar geen fout |

---

## Opruimen

Verwijder in omgekeerde volgorde - resources met afhankelijkheden het eerst:

```bash
cd terraform/aci        && terraform destroy
cd terraform/acr        && terraform destroy
cd terraform/monitoring && terraform destroy
cd terraform/pfsense-azure && terraform destroy
cd terraform/compute    && terraform destroy
cd terraform/network    && terraform destroy
```

---

## Projectstructuur

```
datapunt-5-main/
├── README.md
├── LICENCE
├── .gitignore
├── ansible/
│   ├── site.yml
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── hosts.ini
│   ├── group_vars/
│   │   └── all/
│   │       └── vars.yml          # Gedeelde variabelen (PSK, wachtwoorden)
│   ├── host_vars/
│   │   ├── pfsense-azure.yml     # Variabelen Azure pfSense
│   │   └── pfsense-lab.yml       # Variabelen lab pfSense
│   └── roles/
│       ├── pfsense_ipsec/        # IPsec Phase 1 + 2 configureren
│       └── pfsense_bgp/          # FRR installeren + BGP configureren
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── network/                  # Opdracht 1 - VNet + subnets
    ├── compute/                  # Opdracht 2 - VM's + Azure Files
    ├── acr/                      # Opdracht 3 - Container Registry
    ├── aci/                      # Opdracht 3 - Container Instances
    ├── monitoring/               # Opdracht 4 - Azure Monitor
    ├── pfsense-azure/            # Opdracht 5 - pfSense VM
    ├── cloudinit/
    │   └── gameserver.yaml       # CloudInit script voor VM's
    └── modules/
        ├── vnet/
        ├── vm/
        ├── acr/
        ├── aci/
        ├── monitoring/
        └── storage/
```
