# Security en compliance

> Vertaling van de Zero Trust principes uit `01-principes/security-zero-trust.md` naar de implementatie van Azure-resources in de Terraform bouwblokken.

---

## 1. Zero Trust → Azure mapping

| Kernregel | Azure-implementatie |
|---|---|
| **Geen productiedata** | Ontwikkel/Sandbox Azure Subscriptions bevatten alleen mock of open data. Ingedekt via beleid. |
| **Least privilege** | Enkel specifieke Entra ID (Azure AD) groepen krijgen RBAC rechten op Resource Groepen via `role_assignments` modules. |
| **Authenticatie op elke laag** | Toegang geschiedt enkel door Azure Managed Identities; geen raw credentials voor cloud-to-cloud diensten. |
| **Secrets nooit in code** | Key Vault wordt in de terraform met strikte RBAC en soft-delete (`purge_protection`) geïnitieerd. |

---

## 2. Applicatie (Host-level) Beveiligingsmodel

In situaties waar applicaties op virtuele machines of container platformen binnen een VNet landen, geldt additioneel dit model:

- **OS / Host Firewall**: Default deny incoming op de host, alleen benodigde applicatie en management poorten open (`ufw` of firewalld in linux distros).
- **Docker/Container egress isolatie**: Uitgaand verkeer ("egress") van containers beperken via egress iptables/network-policies, tot een expliciete whitelist (bijv. specifieke API endpoints, identiteit providers, registry).
- **Process tuning**: Applicaties draaien als non-root gebruiker en process namespace is beperkt met properties zoals `cap_drop`.

---

## 3. Azure Policy (Governance in code)

De Terraform templates en/of Landing zone implementatie moeten de volgende policy controls waarborgen:

| Policy | Scope | Doel |
|---|---|---|
| Require tag on resources | Subscription | Verplichte administratieve labels (kostenplaats, eigenaar, fase). |
| Allowed locations | Subscription/Management | Alleen specifieke EER regions toestaan (bijv `westeurope` / `northeurope`). |
| Require secure transfer | Storage | Verplicht HTTPS rest-toegang (TLS 1.2+ minimum). |

---

## 4. Normenkaders: BIO (Overheid) en GDPR

Relevante BIO-maatregelen en hun cloud-configuratie referentie (verantwoord via deze bouwblokken):

| BIO-maatregel | Implementatie aanpak |
|---|---|
| Toegangsbeveiliging | RBAC & PIM via Entra ID en Azure IAM Role Assignments. Privileged credentials rotheren we. |
| Cryptografie | Storage Accounts en PaaS DBs forceren "Encryption at-rest" (Microsoft Managed of Customer Managed Keys in Key Vault). TLS at in-transit verplicht voor web-endpoints. |
| Netwerkscheiding | Applicaties gescheiden in spoke subnets (`snet-app`), databases die niet de publieke cloud routering gebruiken d.m.v. Private Link Endpoints / Subnet Delegation. |
| Logging / Audit | Alle PaaS diensten worden standaard voorzien van een Diagnostische instelling die Audit logs doorstuurt naar een Log Analytics / SIEM. |

### Persoonsgegevens

In Sandbox omgevingen verken je Security-Commons NL projecten of LLM's **zonder persoonsgegevens**. Vanaf Productie gelden de richtlijnen rond de DPIA. Zorg dat de Storage / Logging accounts voorzien zijn van de benodigde "Data Retention Rules" (bijv automatische destructie na X dagen) om opslag minimalisatie af te dwingen.
