# pfSense IPsec VPN 
## Doel
Automatiseer het aanmaken van een IPsec Phase 1 & 2 tunnel op een pfSense firewall via API.


## Vereisten
- pfSense CE **2.8.x**
- pfSense REST API package geïnstalleerd en geactiveerd
- Geldige API gebruiker of een API token
- Ansible geïnstalleerd (getest met Ansible 2.14+)
- Netwerktoegang tot de pfSense API


---

## Gebruik

1. Pas de variabelen aan in: group_vars/all/vars.yml
2. Pas optioneel andere variabelen aan in de inventory file indien nodig.

## Tips
- De pfSense REST API werkt alleen op pfSense 2.8.x
- Configureer een aparte API user met minimaal benodigde rechten
- Test API-toegang altijd eerst met Curl
- REST API documentatie:https://github.com/jaredhendrickson13/pfsense-api
- Installatie REST API package:pkg-static add https://github.com/jaredhendrickson13/pfsense-api/releases/latest/download/pfSense-2.8.1-pkg-RESTAPI.pkg
- WSL-gebruikers dienen rechten goed te zetten en het Ansible-project in de juiste directory te zetten.

## 
Is de code idempotent?


