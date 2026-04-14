# Infrastructure as Code — Terraform

> Geautomatiseerde uitrol van de Azure-omgeving voor AI-ontwikkeling.

---

## Hub-spoke model

Deze Terraform-configuratie werkt binnen het hub-spoke model van de organisatie:

- **VNet en resource group** worden aangemaakt door het infra team (spoke met IP ranges uit IPAM)
- **Netwerkbeveiliging** loopt via de centrale hub firewall (geen NSGs op spoke-niveau)
- **Wij** maken subnets, VM, Key Vault, Storage en monitoring aan binnen de bestaande spoke

## Overzicht

| Module | Resources |
|---|---|
| **network** | Subnets binnen de bestaande spoke VNet |
| **compute** | Linux VM met Docker + Docker Compose (via cloud-init) |
| **data** | Key Vault (RBAC), Storage Account (LRS, TLS 1.2) |
| **monitoring** | Log Analytics workspace, diagnostische instellingen, Azure Policy |

---

## Prerequisites

1. **Azure CLI** geinstalleerd ([installatie-instructies](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
2. **Terraform** >= 1.5.0 geinstalleerd ([installatie-instructies](https://developer.hashicorp.com/terraform/install))
3. **Toegang** tot de Azure subscription (zie [`../01-toegang-en-governance.md`](../01-toegang-en-governance.md))
4. **SSH keypair** aangemaakt (`ssh-keygen -t ed25519`)
5. **Van het infra team**: VNet naam, resource group naam, subnet IP ranges (uit IPAM)

---

## Quickstart

### 1. Inloggen bij Azure

```bash
az login
az account set --subscription "Jouw-Subscription-Naam"
```

### 2. Variabelen aanpassen

Kopieer en pas het `.tfvars` bestand aan voor jouw omgeving:

```bash
cp environments/lokale-omgeving-dev.tfvars environments/jouw-omgeving.tfvars
```

Pas minimaal aan:
- `subscription_id` — je Azure subscription ID
- `resource_group_name` — naam van de door infra team aangemaakte RG
- `vnet_name` — naam van de door infra team aangemaakte spoke VNet
- `subnets` — IP ranges zoals bepaald door infra team (IPAM)
- `storage_account_name` — moet wereldwijd uniek zijn
- `tags` — pas aan naar jouw organisatie

### 3. Initialiseren

```bash
terraform init
```

### 4. Plan bekijken

```bash
terraform plan -var-file=environments/lokale-omgeving-dev.tfvars
```

Review het plan zorgvuldig voordat je doorgaat.

### 5. Uitrollen

```bash
terraform apply -var-file=environments/lokale-omgeving-dev.tfvars
```

Bevestig met `yes` na het reviewen van het plan.

### 6. Outputs bekijken

```bash
terraform output
```

---

## Remote state (aanbevolen)

Voor samenwerking en CI/CD is remote state aanbevolen. Uncomment het `backend "azurerm"` blok in `providers.tf` en pas de waarden aan:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "stterraformstatejouworg"
  container_name       = "tfstate"
  key                  = "jouw-ai-dev.tfstate"
}
```

> Vraag het infra team om een Storage Account voor Terraform state als deze nog niet bestaat.

---

## Modulestructuur

```
infra/
├── main.tf                     # Root module — verbindt alle modules
├── variables.tf                # Invoervariabelen
├── outputs.tf                  # Uitvoer (IP-adressen, IDs, URIs)
├── providers.tf                # AzureRM provider + backend configuratie
├── modules/
│   ├── network/                # Subnets (binnen bestaande spoke VNet)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                # VM + cloud-init (Docker)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── data/                   # Key Vault, Storage Account
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/             # Log Analytics, diagnostics, Azure Policy
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    └── lokale-omgeving-dev.tfvars    # Klantspecifieke waarden
```

---

## Hergebruik door andere gemeenten

Deze modules zijn bewust **generiek** opgezet. Klantspecifieke waarden staan alleen in het `.tfvars` bestand. Om de configuratie te hergebruiken:

1. Kopieer `environments/lokale-omgeving-dev.tfvars` naar bijv. `environments/jouw-omgeving-dev.tfvars`
2. Vraag je infra team om de spoke VNet naam, RG naam en IP ranges
3. Pas de waarden aan (subscription ID, naamgeving, tags, IP-ranges)
4. Draai `terraform plan` en `terraform apply` met jouw `.tfvars` bestand

---

## Opruimen

Om alle resources te verwijderen:

```bash
terraform destroy -var-file=environments/lokale-omgeving-dev.tfvars
```

> **Let op**: Dit verwijdert alle resources inclusief data. Key Vault blijft in soft-deleted state (90 dagen) vanwege purge protection. De spoke VNet en resource group (van het infra team) worden niet verwijderd.

---

## Veelgestelde vragen

### De storage account naam is al bezet

Storage account namen moeten wereldwijd uniek zijn. Kies een andere naam in je `.tfvars` bestand.

### Hoe vraag ik firewall rules aan?

Neem contact op met het infra team. Zie `02-architectuurontwerp.md` sectie "Benodigde firewall rules" voor de lijst van benodigde regels.

### Hoe voeg ik managed PostgreSQL toe?

De managed PostgreSQL (Flexible Server) is voorbereid voor de PoC/pilot-fase. Voeg een `azurerm_postgresql_flexible_server` resource toe aan de `modules/data/` module wanneer je die fase bereikt.

### Hoe schakel ik Private Endpoints in?

Voeg `azurerm_private_endpoint` resources toe voor Key Vault en Storage Account. Dit verhoogt de kosten met ~€7/endpoint/maand maar houdt al het verkeer binnen het VNet.

### Waar bewaar ik Terraform state?

Aanbevolen: in een Azure Storage Account met state locking. Zie de sectie "Remote state" hierboven. Vraag het infra team om een geschikte Storage Account.
