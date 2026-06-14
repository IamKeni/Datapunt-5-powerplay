# Datapunt 5 - Powerplay Infrastructuur

> **Schoolproject · Windesheim Zwolle · ICTCAC · Henry Elsinga**  
> Datapunt 5 - Technische realisatie

---

## Over dit project

Powerplay is een online gamingplatform dat schaalbare en betrouwbare infrastructuur vereist voor gameservers, containers en netwerkverbindingen tussen Azure en een on-premise lab. Dit project realiseert de volledige infrastructuur automatisch via **Terraform** en **Ansible**.

De infrastructuur bestaat uit vijf onderdelen:

| Opdracht | Onderdeel | Technologie |
|----------|-----------|-------------|
| 1 | Netwerk fundament (VNet, subnets, NSG) | Terraform |
| 2 | Compute layer (Linux VM's + Azure Files) | Terraform + CloudInit |
| 3 | Container platform (ACR + ACI + Docker) | Terraform + Docker |
| 4 | Monitoring (Azure Monitor + Alerts) | Terraform |
| 5 | pfSense gateway + IPsec/BGP routering | Terraform + Ansible |

---

## Aan de slag

De volledige installatiehandleiding - inclusief vereisten, deployvolgorde, configuratie en verificatie - vind je in de map met de code:

**[📖 Installatiehandleiding → datapunt-5-main/README.md](./datapunt-5-main/README.md)**
