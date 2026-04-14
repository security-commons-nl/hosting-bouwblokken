# Architectuurontwerp

> Technisch ontwerp van de referentie Azure-omgeving: netwerk, compute, data, AI/ML en hun samenhang.

---

## Architectuurdiagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                             Azure Hub                                   │
│                   (beheerd door centraal infra team)                    │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Azure Firewall (centraal, default dicht)                        │   │
│  │  Alle spoke-verkeer stroomt idealiter via hub firewall.          │   │
│  │  Firewall rules aanvragen bij infra team.                        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────────────┘
                             │ Route table / VNet peering
┌────────────────────────────┴────────────────────────────────────────────┐
│                        Azure Subscription                               │
│                         "[Jouw-Subscription]"                           │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  VNet: vnet-ai-dev-01 (<VNET_CIDR>, gepeered met hub)             │  │
│  │                                                                   │  │
│  │  ┌──────────────────────┐  ┌──────────────────────┐               │  │
│  │  │ snet-ai-app-01       │  │ snet-ai-data-01      │               │  │
│  │  │                      │  │                      │               │  │
│  │  │  ┌────────────────┐  │  │  ┌────────────────┐  │               │  │
│  │  │  │ vm-ai-app-01   │  │  │  │psql-ai-app-01  │  │               │  │
│  │  │  │                │  │  │  │ (PostgreSQL    │  │               │  │
│  │  │  │ Docker Compose │  │  │  │  Flexible)     │  │               │  │
│  │  │  │ ┌────────────┐ │  │  │  └────────────────┘  │               │  │
│  │  │  │ │ frontend   │ │  │  │                      │               │  │
│  │  │  │ │ api        │ │  │  └──────────────────────┘               │  │
│  │  │  │ └────────────┘ │  │                                         │  │
│  │  │  └────────────────┘  │                                         │  │
│  │  └──────────────────────┘                                         │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌───────────────┐    │
│  │ kv-ai-app-01        │  │ sa-ai-app-01        │  │ log-ai-01     │    │
│  │ (Key Vault)         │  │ (Storage Account)   │  │ (Log Analytics│    │
│  └─────────────────────┘  └─────────────────────┘  └───────────────┘    │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                Azure AI Foundry (West Europe)                    │   │
│  │                Open-source modellen (Mistral, Llama, Phi)        │   │
│  │                Pay-per-token                                     │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Netwerk

### Hub-spoke model

We raden aan dat netwerkbeveiliging het hub-spoke model van je organisatie volgt:

| Aspect | Verantwoordelijkheid |
|---|---|
| **Hub + Azure Firewall** | Centraal Infra team — beheer, default dicht |
| **Spoke VNet + route table** | Centraal Infra team — creatie van het gesegmenteerde VNet |
| **Resource group + tags** | Aangemaakt via IaC, erven tags |
| **Subnets binnen spoke** | AI/App team — via Terraform |

> **Best Practice**: Als al het verkeer al geforceerd via een Hub Firewall loopt, overweeg dan het gebruik van extra NSG regels (in de spoke) om de interne *east-west* verbindingen te dichttimmeren, afhankelijk van hoe strict de compliancy is.

### Subnets

Wij maken typisch subnets aan binnen de bestaande spoke VNet (`<VNET_CIDR>`):

| Subnet | Doel |
|---|---|
| `snet-ai-app-01` | Applicatie workload (VM / Container Apps) |
| `snet-ai-data-01` | Managed databases (Delegated), private endpoints |

### Benodigde communicatie

| Verkeer | Bron | Bestemming | Poort | Reden |
|---|---|---|---|---|
| SSH/RDP | Beheer/VPN | Applicatie | 22/3389 | Beheer van workloads |
| HTTPS in | Intern netwerk | Applicatie | 443 | Gebruikerstoegang |
| HTTPS out | Applicatie | Internet | 443 | Container images, AI API calls, OIDC Entra auth |

### Private Endpoints

Voor Tier 2 en Productie gebruiken we Private Endpoints zodat verkeer naar managed PaaS diensten binnen het VNet blijft:
- Key Vault → Private Endpoint
- Storage Account → Private Endpoint
- PostgreSQL Flexible Server → VNet-integratie (delegated subnet)

---

## 2. Compute (Sandbox Focus in Terraform)

Voor de sandbox tier maakt de configuratie gebruik van een enkele "dikke" VM met Docker Compose:

### Docker Compose stack referentie

Container-hardening conform best practices:

```yaml
services:
  api:
    image: ghcr.io/security-commons-nl/applicatie-api:1.0.0
    ports:
      - "127.0.0.1:8000:8000"    # Alleen loopback; laat reverse proxy de ingress afhandelen
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    mem_limit: 1g
```

**Container-hardening regels**:
- **Gepinde image versies**: Geen `:latest` — voorkomt onverwachte breaks en kwetsbaarheden
- **Poorten op loopback**: `127.0.0.1:port:port` — niet `0.0.0.0`
- **`no-new-privileges` + `cap_drop`**: Voorkomt privilege escalatie en verwijdert overbodige linux capabilities.

### Cloud-init Hardening
De VM wordt via cloud-init automatisch geconfigureerd (zie terraform repo's voor de templates):
1. **SSH hardening**: Geen root login, geen wachtwoord, key-only.
2. **Docker egress firewall**: whitelist-based uitgaand verkeer via iptables rules in de container netwerk bridge.
3. **VM auto-shutdown**: Stop de Dev VM om 18:00 ter besparing.

---

## 3. Data

### Azure Key Vault of vergelijkbaar
| Doel | Database-wachtwoorden, API-keys, certificaten |
|---|---|
| Authenticatie | RBAC-gebaseerd in plaats van oude Access Policies |
| Beveiliging | Soft delete actief, purge protection actief |

> **Kernregel**: Secrets **nooit** in code. Altijd via Managed Identity naar een Key Vault en daar als in-memory variable inladen.

---

## 4. AI / Machine Learning

We kiezen bewust voor **cloud-hosted API's via open modellen** in plaats van lokale GPU-inferentie in de eerste fases, vanwege kostenefficiëntie. Pas bij gigantisch volume loont lokale inferentie op zware (tegenwoordig schaarse) GPU machines.

| Aanpak | Waarmee |
|---|---|
| Open Modellen | Llama, Mistral open-weights via Azure AI Foundry of Mistral la Plateforme |
| Vector Search | PostgreSQL extensie `pgvector`. Integratie met AI orchestrator via standaard SQL drivers. |

---

## 5. Schaalpad

```
Sandbox/Dev (Tier 1)            Pilot (Tier 2)               Productie (Tier 3)
─────────────────────────────────────────────────────────────────────────────
1x VM + Docker Compose    →    AKS / Container Apps     →    Container Apps / AKS multi-zone
PostgreSQL in Docker      →    Flex Server (burst)      →    Flex Server (HA + geo-backup)
Firewall default rules    →    + Private Endpoints      →    + WAF / Front Door
Geen SLA                  →    Minimal SLA              →    99.9% / High Availability
```
Dit ontwerp is bewust **incrementeel**: we beginnen klein en schalen de infrastructuur (en bijbehorende Terraform code) alleen op wanneer de Security-Commons applicatie werkelijk in de asiel/productie fase landt.
