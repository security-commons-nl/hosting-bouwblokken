# Toegang en governance

> Hoe krijg je toegang tot de Azure-omgeving en hoe beheren we resources op een gestructureerde manier?

---

## 1. Toegang tot de subscription

Je applicatie draait idealiter binnen een specifieke Azure subscription (bijv. `[Project-AI-Dev]`) binnen de Entra ID tenant van je organisatie (`[jouw-tenant].onmicrosoft.com`).

### Stappenplan voor developers

1. **Entra ID-account**: Zorg dat je een account hebt in de tenant.
2. **Toegang aanvragen**: Dien een verzoek in bij je Azure-beheerder / Infra team voor:
   - **Rol**: `Contributor` op Resource Group niveau (niet op subscription-niveau)
   - **Scope**: De specifieke Resource Group(s) waar je in werkt
3. **MFA activeren**: Multi-Factor Authentication is verplicht.
4. **Conditional Access**: Toegang is alleen mogelijk vanaf goedgekeurde netwerken/apparaten conform het bedrijfsbeleid.

### Rolverdeling

| Rol | Scope | Wie |
|-----|-------|-----|
| Owner (Eligible, PIM) | Subscription | AI-teamleden / Tech Leads — activeren vóór gebruik |
| Owner | Subscription | Azure-beheerder Infra Team |
| Reader | Resource Group | Stakeholders, security officers, auditors |
| Key Vault Secrets User | Key Vault resource | Applicaties en CI/CD pipelines die secrets nodig hebben |

> **Let op**: Vraag altijd de minimaal benodigde rol aan (least privilege). Contributor op subscription-niveau wordt idealiter niet structureel verstrekt.

---

## 2. Resource Group strategie

Het is aan te raden één centrale RG voor gedeelde netwerk resources aan te houden, en een aparte RG per onafhankelijke applicatie. 

| Resource Group | Doel | Voorbeeldresources |
|---|---|---|
| `rg-infr-001-d` | Centrale/gedeelde resources | VNet, Log Analytics, Defender |
| `rg-ai-app-001-d` | Specifieke applicatie | VM, PostgreSQL, Key Vault |

Tags worden idealiter geërfd via de Resource Group — dit maakt kostenuitsplitsing per applicatie mogelijk.

---

## 3. Naamgevingsconventie

We adviseren een landelijke of organisatiespecifieke naamgevingsstandaard te volgen. Een veelvoorkomend patroon is:

```
<resourceafkorting>-<domein>-[<app>-]<volgnummer>-<omgeving>
```
*Voorbeeld: `kv-ai-anonimizer-001-d` (Key Vault, AI domein, applicatie Anonimizer, nummer 1, Development).*

| Resource | Centraal | Applicatie-specifiek |
|---|---|---|
| Resource Group | `rg-ai-001-d` | `rg-ai-app-001-d` |
| Virtual Network | `vnet-ai-001-d` | — |
| Subnet | — | `snet-ai-app-001-d` |
| Virtual Machine | — | `vm-ai-app-001-d` |
| Key Vault | — | `kv-ai-app-001-d` |
| Log Analytics | `log-ai-001-d` | — |

---

## 4. Tags

Elke resource moet voorzien zijn van vaste tags (af te dwingen via verplichte Azure Policies):

| Tag | Verplicht | Voorbeeld |
|-----|-----------|-----------|
| `eigenaar` | Ja | `ai-team` |
| `project` | Ja | `beleid-assistent` of `sandbox` |
| `kostenplaats` | Ja | `1234-IT` |
| `omgeving` | Ja | `dev`, `tst`, `acc`, `prd` |

---

## 5. Kostenbeheer

Stel budget alerts in via Azure Cost Management op het niveau van de Subscription of Resource Group:

| Alert | Drempel | Actie |
|-------|---------|-------|
| Waarschuwing | 80% van maandbudget | E-mail aan Product Owner |
| Kritiek | 100% van maandbudget | E-mail aan PO + beheerder |
| Overschrijding | 120% van maandbudget | E-mail aan management |

**Cost Management tips:**
- Zet Dev/Test VM's uit buiten werktijden (bespaart ~60% op compute). Gebruik `auto-shutdown` schedules.
- Verwijder ongebruikte resources (unattached disks, orphaned public IPs).
