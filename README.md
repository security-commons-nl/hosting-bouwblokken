# Secure Hosting Bouwblokken

Welkom bij de **Secure Hosting Bouwblokken** repository, onderdeel van [Security-Commons-NL](https://github.com/Security-Commons-NL).

[![Bijdragen](https://img.shields.io/badge/📝_Bijdragen-Open_een_bericht-238636?style=for-the-badge)](../../issues/new/choose)&nbsp;&nbsp;&nbsp;&nbsp;[![Discussions](https://img.shields.io/badge/💬_Discussions-Meepraten-0969da?style=for-the-badge)](../../discussions)

👉 **Iets delen, feedback geven of een vraag stellen?** Klik op een van de knoppen hierboven — geen Git-ervaring nodig. Zie [CONTRIBUTING.md](CONTRIBUTING.md) voor meer opties.

Deze repository biedt generieke, herbruikbare referentiearchitecturen, Infrastructure-as-Code (IaC) templates en best practices voor het veilig en soeverein hosten van (Gen)AI- en beveiligingsapplicaties binnen Nederlandse gemeenten en overheidsinstanties.

Dit project is van oorsprong gebaseerd op praktijkervaringen en architectuurdesigns vanuit de Gemeente Leiden (de voormalige *ai-dev-blueprint*), en is geanonimiseerd en veralgemeniseerd zodat iedere organisatie deze fundamenten kan gebruiken.

## Waarom deze repository?

Wanneer gemeenten aan de slag gaan met open-source innovaties uit Security-Commons-NL (zoals de *Anonimizer*, *Beleid-assistent* of *CISO Chat*), lopen zij vaak tegen dezelfde infrastructurele uitdagingen aan:
- Hoe zorgen we dat de data binnenshuis (soeverein) blijft?
- Hoe implementeren we een veilige test/sandbox omgeving zonder onnodig hoge cloud kosten?
- Welke container- en netwerk-hardening regels moeten we toepassen?
- Hoe bouwen we volgens de Zero Trust principes op Azure of andere cloud platformen?

Deze repository lost dit op door modulaire **bouwblokken** aan te bieden.

## Kernprincipes

1. **Soevereiniteit First:** Voorkeur voor open-source modellen en technologieën. Data verlaat de Europese Economische Ruimte (EER) niet.
2. **Zero Trust:** Vertrouw geen enkele netwerklaag; verifieer álles. Gebruik van strikte RBAC, Private Endpoints, en default-deny netwerk- en applicatieregels.
3. **Schaalbaarheid (Sandbox tot Productie):** Begin klein en goedkoop (bijv. een enkele hardened VM met Docker Compose) en schaal organisch op naar volwassen enterprise architecturen (zoals Managed databases en Kubernetes/Container Apps).
4. **Infrastructure as Code (IaC):** Architectuur en configuratie is vastgelegd in Terraform. Lokale clicks in een Cloud portal worden vermeden.

## Structuur (In Ontwikkeling)

Momenteel werken we aan het integreren en structureren van de volgende componenten:
- **01-principes/** - Architectuurvisies, Zero Trust fundering en werkafspraken.
- **02-architecturen/** - Overkoepelende technische ontwerpen (Sandbox, Pilot, Productie).
- **03-infrastructure/** - Herbruikbare Terraform modules voor cloud-omgevingen (startend met Azure).
- **04-guides/** - Applicatiespecifieke implementatiegidsen voor Security-Commons-NL projecten.

## Verder lezen

Bekijk de [ROADMAP.md](ROADMAP.md) voor de geplande ontwikkeling van deze repository.

## Bijdragen

Zie [CONTRIBUTING.md](CONTRIBUTING.md) voor hoe je iets kan delen, melden of verbeteren — met of zonder Git-ervaring.
