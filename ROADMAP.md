# Roadmap: Secure Hosting Bouwblokken

Dit document beschrijft de geplande ontwikkeling voor de `hosting-bouwblokken` repository binnen Security-Commons-NL. De oorspronkelijke blueprint komt uit een praktijkomgeving bij een Nederlandse gemeente en is geanonimiseerd tot een generiek inzetbare architectuur-standaard voor de Nederlandse (lokale) overheid.

---

## Fase 1: Fundament & Opschoning ✅

- [x] Initialisatie van de repository (README, ROADMAP).
- [x] Migratie van nuttige documentatie uit de originele blueprint.
- [x] Anonimiseren van domeinen, specifieke netwerk ranges, persoonsgegevens en e-mailadressen.
- [x] Opschonen van klantspecifieke Cloud Subscription benamingen.
- [x] Azure-specifieke implementaties geïsoleerd in eigen mappen (`02-architecturen/azure/`, `03-infrastructure/azure/`).
- [x] Principes (Zero Trust, Architectuur) als cloud-agnostische documenten in `01-principes/`.

---

## Fase 2: Architectuur Tiers & Terraform Modules

### Documentatie
- [x] **Tier 1 (Sandbox)** gedocumenteerd: VM + Docker Compose, container-hardening, auto-shutdown, ~€100/maand.
- [ ] **Tier 2 (Pilot/PoC)** uitwerken: Managed PostgreSQL (Flexible Server + pgvector), Private Endpoints, Defender for Servers, ~€200/maand.
- [ ] **Tier 3 (Productie)** uitwerken: AKS / Container Apps, WAF / Front Door, High Availability, SIEM-integratie, ~€600+/maand.

### Terraform Modules
- [x] Basismodules gemigreerd en geanonimiseerd: `network`, `compute`, `data`, `monitoring`.
- [ ] Module toevoegen: **Azure Database for PostgreSQL Flexible Server** (met `pgvector` extensie, VNet-integratie, automated backups).
- [ ] Module toevoegen: **Azure Container Apps** als lichtgewicht productie-platform (alternatief voor AKS bij kleinere teams).
- [ ] Module toevoegen: **Private Endpoints** voor Key Vault, Storage en PostgreSQL.
- [ ] Module toevoegen: **Azure Front Door / Application Gateway** met WAF-regels.

---

## Fase 3: CI/CD & Automatisering

- [ ] **GitHub Actions workflows** toevoegen (`.github/workflows/`):
  - `terraform-plan.yml` — Automatisch plan bij elke PR (met OIDC auth, geen vaste credentials).
  - `terraform-apply.yml` — Gecontroleerde apply na PR-approval.
  - `security-scan.yml` — Automatische scans met `tfsec`, `checkov` of `trivy` op elke commit.
- [ ] **Container image scanning** pipeline: automatisch scannen van Docker images op kwetsbaarheden voordat ze uitgerold worden.
- [ ] **Documentatie-generatie**: automatisch genereren van Terraform module-documentatie via `terraform-docs`.

---

## Fase 4: Integratie-gidsen voor Security-Commons-NL Tools

Per Security-Commons-NL project een concrete "van nul tot draaiend" deployment guide in `04-guides/`:

- [ ] **Anonimizer**: Docker Compose configuratie, volume mappings voor datasets, netwerktoegang, integratie met Key Vault voor API-keys.
- [ ] **Beleid-assistent**: LLM-API configuratie (Azure AI Foundry / Mistral), RAG-pipeline met pgvector, reverse proxy setup.
- [ ] **CISO Chat**: Chatbot deployment, Entra ID authenticatie-integratie, logging van gesprekken naar Log Analytics.
- [ ] **GRC Platform**: Database migraties, multi-user RBAC setup, compliance dashboard configuratie.
- [ ] Generiek patroon documenteren: hoe voeg je een **nieuwe** Security-Commons tool toe aan de infrastructuur (stappenplan met checklist).

---

## Fase 5: Responsible AI Beleidskader

- [ ] Generiek **Responsible AI** beleidsdocument schrijven (gebaseerd op het oorspronkelijke gemeentelijke AI-principesdocument, maar breed toepasbaar).
- [ ] Koppeling met de **EU AI Act** verplichtingen voor overheden (risicoclassificatie, transparantie-eisen, algoritmeregister).
- [ ] Checklist: "Mag ik dit AI-model inzetten?" — beslisboom voor overheden op basis van dataclassificatie, risicoprofiel en wettelijke kaders.
- [ ] Template voor een **DPIA** (Data Protection Impact Assessment) specifiek voor GenAI-toepassingen bij gemeenten.

---

## Fase 6: Multi-Platform & On-Premise

- [ ] **Proxmox / bare-metal** deployment guide: voor organisaties die volledige datasoevereiniteit eisen zonder public cloud. Inclusief:
  - Netwerksegmentatie met VLANs en pfSense/OPNsense.
  - VM-provisioning met cloud-init of Ansible.
  - Container orchestratie via Docker Compose of lightweight K3s.
- [ ] **AWS** referentie-architectuur: vertaling van de Azure bouwblokken naar VPC, ECS/EKS, Secrets Manager, CloudWatch.
- [ ] **Hetzner / Scaleway** als Europese budget-cloud alternatieven documenteren (voor organisaties zonder enterprise cloud contract).

---

## Fase 7: Community & Governance

- [ ] **CONTRIBUTING.md** schrijven: hoe kunnen andere gemeenten, security professionals of developers bijdragen?
- [ ] **Issue templates** opzetten: bug reports, feature requests, nieuwe tool-integraties.
- [ ] **Changelog** bijhouden (CHANGELOG.md) zodat afnemers kunnen zien wat er per versie is gewijzigd.
- [ ] **Licentiekeuze** formaliseren (bijv. EUPL-1.2 als Europese open-source licentie, of Apache 2.0).
- [ ] Periodieke **security review** van de Terraform modules en hardening-configuraties (bijv. per kwartaal).

---

*Deze roadmap wordt dynamisch bijgewerkt op basis van inzichten vanuit de community, wijzigende security-eisen (BIO 2.0, NIS2) en de Europese AI Act.*

