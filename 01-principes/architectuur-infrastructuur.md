# Architectuur & Infrastructuur

## Cloud Omgeving

Het AI-team opereert idealiter binnen een specifieke **Subscription** of **Project**, onderdeel van de cloud tenant van je organisatie.

- Alle experimenten draaien binnen deze afgescheiden omgeving
- In de sandbox-fase draaien geen productie-workloads en staat er geen gevoelige data in de cloud
- Beheer (en kostenbeheersing) is belegd bij de AI Product Owner / Project Lead

## Uitgangspunten

- **Soevereiniteit first**: voorkeur voor open-source tooling en modellen boven closed-source SaaS-diensten (om vendor lock-in te voorkomen en autonomie te behouden).
- **Data binnen de EER**: data en AI-modellen worden uitsluitend opgeslagen en verwerkt binnen de Europese Economische Ruimte (EER). Contractueel moet worden vastgelegd dat data van je organisatie niet wordt gebruikt voor het trainen van commerciële third-party modellen.
- **Gescheiden netwerken**: de ontwikkelomgeving is uitsluitend bedoeld voor experimenten, PoC's en pilots, fysiek en netwerk-technisch gescheiden van het interne productienetwerk.
- **Infrastructure as Code**: alle omgevingsconfiguraties worden als code opgeslagen in een repository (Terraform/Bicep), niet via handmatige portal-configuratie.
- **AI-lifecycle management**: AI-assets (modellen, datasets, configuraties) worden centraal geregistreerd met versiebeheer, zodat beheersbaarheid en reproduceerbaarheid geborgd zijn.

## Preferred Stack (Referentie)

Voor de blauwdrukken in deze repository maken we primair gebruik van de volgende referentiestack:

| Laag | Voorkeur |
|------|----------|
| Cloud | Azure (of alternatieve public/on-prem cloud) |
| Modellen | Open-source via Hugging Face / Azure AI Foundry / Lokale Ollama |
| Orkestratie | LangChain, Semantic Kernel, custom Python |
| Opslag | Blob Storage / S3-compatible opslag (met mock data voor in de sandbox) |
| Identity | Azure Entra ID / Keycloak (Zero Trust, zie [security-zero-trust](security-zero-trust.md)) |

## Wijzigingsbeheer

Architectuurkeuzes worden vastgelegd in de project repository.
