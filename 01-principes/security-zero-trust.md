# Security & Zero Trust

## Principe

> **Elke oplossing, ook in de sandbox, wordt gebouwd op Zero Trust.**

Vertrouw niets, verifieer alles. Geen enkel component — intern of extern — wordt standaard vertrouwd.

## Kernregels

1. **Nooit productiedata** — uitsluitend mock data of puur openbare data in de ontwikkel/sandbox omgeving.
2. **Least privilege** — elke service, gebruiker en component krijgt minimaal de rechten die nodig zijn.
3. **Authenticatie op elke laag** — ook interne service-to-service communicatie wordt geauthenticeerd (bijv. Azure Managed Identity, Entra ID of mTLS).
4. **Secrets nooit in code** — gebruik veilige secret stores (zoals Azure Key Vault, HashiCorp Vault); geen API-keys, wachtwoorden of tokens in repositories of lokale configuratiebestanden.
5. **Auditlogging** — alle acties worden gelogd en traceerbaar gemaakt.

## Gelaagde beveiliging (Defense in Depth)

```
[ Identity & Access (IdP / RBAC) ]
        ↓
[ Netwerk (VNet, NSG / Firewall, Private Endpoints) ]
        ↓
[ Applicatielaag (input-validatie, rate limiting, container isolation) ]
        ↓
[ Data (encryptie at rest & in transit) ]
        ↓
[ Monitoring & Alerting (SIEM / SOC Integratie) ]
```

## AI-specifieke risico's

| Risico | Maatregel |
|--------|-----------|
| Prompt injection | Input-sanitatie + output-validatie (bijv. LlamaGuard) standaard toepassen |
| Model lekkage | Geen training van closed-source modellen op gevoelige data, enkel RAG |
| Supply chain | Pinnen van model-versies (SHA-hashes) en container dependencies |
| Ongecontroleerde output | Human-in-the-loop bij risicovolle acties |

## Responsible AI

Lokale AI Principes van je organisatie (zoals algoritmeregisters of wetgevingskaders) vullen deze technische security documenten aan. Zero Trust borgt de technische beveiliging, terwijl lokale kaders de bestuurlijke en maatschappelijke verantwoordelijkheid borgen.

## Eigenaarschap

De CISO / Security Officer is sparringpartner voor dit document. Eindverantwoordelijkheid voor projectbeveiliging ligt bij de betreffende Product Owner.
