# Azure Reference Deployment

> Concrete uitwerking van de Secure Hosting Bouwblokken principes naar een veilige, compliante en soevereine Azure-omgeving voor lokale overheden.

---

## Leeswijzer

Deze map vertaalt de generieke Zero Trust principes uit `01-principes/` naar een werkende Azure-implementatie. De documenten zijn zelfstandig leesbaar.

| Dit document | Bouwt voort op |
|---|---|
| `01-toegang-en-governance.md` | `01-principes/architectuur-infrastructuur.md` |
| `02-architectuurontwerp.md` | `01-principes/architectuur-infrastructuur.md` |
| `03-security-en-compliance.md` | `01-principes/security-zero-trust.md` |
| `04-kosten-en-sizing.md` | — |

Voor de daadwerkelijke Terraform (Infrastructure as Code) bestanden, zie de map `03-infrastructure/azure/`.

## Overzicht documenten

1. **[Toegang en governance](01-toegang-en-governance.md)** — Subscription-toegang, RBAC, naamgeving, tags, kosten
2. **[Architectuurontwerp](02-architectuurontwerp.md)** — Netwerk, compute, data, AI/ML met diagrammen
3. **[Security en compliance](03-security-en-compliance.md)** — Zero Trust → Azure, BIO, AVG/GDPR
4. **[Kosten en sizing](04-kosten-en-sizing.md)** — SKU-keuzes, maandkosten, schaalpad

## Wat wordt er (met Terraform) uitgerold?

De referentie Terraform-code rolt een complete, geharde Azure-omgeving uit:

**Netwerk & toegang**
- VNet met gescheiden subnets per workload (applicatie, sandbox, data)
- NSGs met deny-all-inbound defaults + NSG flow logs
- Azure Policy

**Compute (VM + Docker)**
- Ubuntu 22.04 VM met cloud-init provisioning
- SSH hardening: geen root login, geen wachtwoord, key-only
- Kernel hardening: anti-spoofing, pointer restrictions
- Docker egress firewall: whitelist-based uitgaand verkeer

**Data**
- Key Vault met RBAC, soft delete, purge protection
- Storage Account: TLS 1.2, public access geblokkeerd

**Monitoring & governance**
- Log Analytics workspace
- NSG flow logs
- Budget alerts
