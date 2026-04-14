# Kosten en sizing

> Geschatte maandkosten, SKU-keuzes en schaalpad voor een Security/AI-applicatie (bijv. de Anonimizer of Beleidsassistent) op Azure.

---

## 1. Sandbox-fase (Schatting ~€100/maand)

In een experimentele sandbox willen we initieel niet investeren in dure managed infrastructuur zolang de applicatie geen kritieke afhankelijkheid is. We implementeren in dergelijke gevallen vaak de databases in containers via docker-compose binnen de virtuele testmachine zelf.

| Resource | Verwachte SKU | Doel | ~Kosten/maand |
|---|---|---|---|
| Virtual Machine (App Server) | `Standard_B2ms` (2 vCPU, 8 GB RAM) | Burstable VM voor web+app containers | €60 |
| Managed Disk | P6 Premium SSD (64GB) of lager | Opslag containers & container DB's | €10 |
| Key Vault | Standard | Secrets & Certificaten generiek | €1-2 |
| Storage Account | Standard LRS Hot | Bestandsuploads, AI document pipeline | €2-5 |
| Log Analytics | Pay-as-you-go | (Gratis niveau afhankelijk van EA/MACC) | €0-5 |
| Azure AI Foundry / OpenAI | Pay-per-token | Open Modellen consumptie | Variabel, ca. €10-20 |
| **Totaal indicatie** | | | **~€90-110/maand** |

### Kostenbesparing tips
| Maatregel | Besparing |
|---|---|
| VM auto-shutdown d.m.v. tag beleid buiten kantooruren (18:00-08:00 + weekenden). | ~60% op compute! |
| Reserve Instances inzetten (bij transitie naar Tier 2 / 3) | ~30% op basis compute |

---

## 2. PoC/Pilot of Enterprise-fase (Schatting ~€300+/maand)

Zodra de tool daadwerkelijk data van eindgebruikers verwerkt en beschikbaarheid (HA/SLA) verwacht wordt, is een losse virtuele machine niet langer voldoende. 

| Uitbreiding t.o.v Sandbox | Waarom | Impact op prijs (indicatie) |
|---|---|---|
| Azure Container Apps / AKS | High Availability platform in multizone. | +€100-200 afhankelijk van workload scale |
| PostgreSQL Flexible / Azure SQL | Managed backups, failovers, encryptie via platform in plaats van binnen de VM risk. | +€50 (basis scale) tot €200 (HA sku's) |
| Private Endpoints | Volledige isolatie van PaaS diensten op het VNet. | +€7 / IP endpoint per account |
| Web Application Firewall | Borgen L7 security en ingress DDos bescherming | +€200 (Application Gateway / Front Door) |

---

## 3. SKU-vergelijking (Compute referentie)

| SKU | vCPU | RAM | Geschikt voor (in theorie) |
|---|---|---|---|
| `Standard_B1ms` | 1 | 2 GB | Kleine Python scripts, simpele jobs |
| `Standard_B2ms` | **2** | **8 GB** | **Voldoende voor de gemiddelde sandbox (DB + API + WebApp)** |
| `Standard_B4ms` | 4 | 16 GB | Grotere pilots pre-Container Apps migratie |

**Burstable Instances (B-series):** Een aanrader voor de Azure bouwstenen doordat applicaties zoals een AI Assistent of CISO chatbot over het algemeen kort cyclisch veel CPU gebruiken, om daarna een tijd stil te staan. Dit type licenties bespaart significant tressen vergeleken met de "Always On" Compute (D-Series).
