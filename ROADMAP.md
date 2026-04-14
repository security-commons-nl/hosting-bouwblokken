# Roadmap: Secure Hosting Bouwblokken

Dit document beschrijft de geplande ontwikkeling voor de `hosting-bouwblokken` repository binnen Security-Commons-NL. Het doel is om in iteratieve fases de blueprint vanuit Gemeente Leiden om te bouwen tot een generiek inzetbare architectuur-standaard voor de Nederlandse overheid.

## Fase 1: Fundament & Opschoning (Huidig)
- [x] Initialisatie van de repository.
- [ ] Voorbereiden migratie: Kopiëren van nuttige documentatie uit de originele *ai-dev-blueprint*.
- [ ] Anonimiseren van domeinen, specifieke netwerk ranges (CIRD/VNet info), en persoonsgegevens.
- [ ] Opschonen van klantspecifieke Cloud Subscription benamingen ("Leiden-AI-dev" vervangen door generieke benamingen).
- [ ] Herschrijven van Azure specifieke taal naar generieke "Cloud / On-Prem" principes, waar mogelijk, en Azure-specifieke implementaties isoleren in een eigen map (`03-infrastructure/azure/`).

## Fase 2: Architectuur en Modulatie
- [ ] **Architectuur Tiers Documenteren:**
  - **Tier 1 (Sandbox):** Kosten-efficiënte inzet op basis van enkele VM's, Docker Compose, SQLite/Lokale DB's en geharde netwerk ingress (focus op intern experimenteren).
  - **Tier 2 (Pilot/PoC):** Introductie van Managed Services (zoals Managed PostgreSQL met pbouncer/pgvector), scheiding van VNet subnetten per workload, en opzetten Private Endpoints.
  - **Tier 3 (Productie):** Volledige implementatie met AKS / Container Apps, Web Application Firewalls (WAF), High Availability, uitgebreide logging / SIEM integratie en geautomatiseerde failovers.
- [ ] **Terraform Modules Opzetten:** Opschonen en ombouwen van de originele Terraform (`infra/`) code naar herbruikbare modules zonder hardcoded waarden.

## Fase 3: Integratie met Security-Commons
- [ ] Opzetten van integratie-guides voor het uitrollen van specifieke Security-Commons-NL tools bovenop deze infrastructuur.
  - Deployment guide: *Anonimizer*
  - Deployment guide: *Beleid-assistent*
  - Deployment guide: *CISO Chat*
- [ ] Documenteren van het proces om specifieke tools toegangelijk te maken via het Zero Trust model (zoals API Gateway en RBAC implementaties).

## Fase 4: Multi-Cloud & Uitbreiding (Toekomstvisie)
- [ ] Onderzoeken en toevoegen van vergelijkbare ontwerppatronen voor AWS en Google Cloud Platform, ten behoeve van gemeenten zonder Azure footprint.
- [ ] Aanbieden van "Local on-prem" bare-metal / Proxmox deployment guides (voor volledige datasoevereiniteit zonder Public Cloud).

---

*De roadmap wordt dynamisch bijgewerkt o.b.v. inzichten vanuit de community en wijzigende security eisen (zoals BIO-richtlijnen en NIS2).*
