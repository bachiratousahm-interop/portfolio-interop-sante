# Projet 5 - Architecture d'intégration SI Santé

## Clinique Sainte-Marie - Cas pédagogique

Ce projet constitue la **synthèse du portfolio Interopérabilité SI Santé**.

À partir du cas fictif de la Clinique Sainte-Marie, l'objectif est de proposer une trajectoire d'évolution d'un SI hospitalier hétérogène vers une architecture d'intégration plus centralisée, interopérable et sécurisée.

> Cas pédagogique - données et systèmes simulés.

---

## Architecture proposée

L'architecture articule :

- HL7 v2 pour les flux hospitaliers existants ;
- Mirth Connect pour l'intégration et les transformations ;
- FHIR R4 / HAPI FHIR pour l'exposition des données ;
- INS comme identité de référence cible ;
- XDS.b / MHD pour la trajectoire documentaire ;
- OAuth2 / SMART on FHIR pour la sécurisation des accès.

![Architecture cible](./diagrams/figure-1-architecture-cible.png)

Le détail des choix d'architecture, des ADR et de la gouvernance est disponible dans le DAT.

---

## POC réalisés

### HL7 v2 vers FHIR avec Mirth Connect

Trois expérimentations ont été réalisées :

| Flux | Résultat FHIR |
|---|---|
| ADT^A01 | Patient |
| ADT^A01 + PV1 | Patient + Encounter |
| ORU^R01 | Observation |

Les messages HL7 v2 sont injectés via **netcat** sur les listeners MLLP afin de simuler les applications sources.

Le POC couvre notamment :

- transformation HL7 v2 vers FHIR en JavaScript ;
- Bundle Transaction ;
- PUT conditionnel pour limiter les doublons Patient ;
- référence conditionnelle vers le Patient ;
- Location contenue dans Encounter ;
- filtres Source et Destination ;
- diagnostic et rejeu de messages dans Mirth.

![Mapping HL7 v2 vers FHIR](./diagrams/figure-2-mapping-hl7-fhir.png)

![Canaux Mirth Connect](./diagrams/figure-3-canaux-mirth.png)

Les exports et captures techniques détaillés sont disponibles dans le dossier Mirth dédié du portfolio.

---

### OAuth2 / SMART on FHIR

Un POC d'accès au serveur FHIR a été réalisé avec **Keycloak** :

`Keycloak -> JWT avec scopes SMART -> Bearer token -> HAPI FHIR -> HTTP 200`

![OAuth2 SMART on FHIR](./diagrams/figure-4-smart-on-fhir.png)

L'appel FHIR avec token a été validé avec une réponse HTTP `200 OK`.

L'application effective des scopes comme règles d'autorisation côté HAPI FHIR n'a pas été implémentée : l'`AuthorizationInterceptor` reste hors périmètre du POC.

---

## Périmètre et limites

Le projet distingue volontairement les **éléments expérimentés** de l'**architecture cible**.

Non implémentés dans le POC :

- connexion réelle à Orbis, Sysmex, Sectra ou Génois ;
- enforcement des scopes SMART côté HAPI FHIR ;
- API Gateway industrialisée ;
- connexion réelle à INSi / DMP ;
- infrastructure XDS.b / MHD complète.

Les environnements du portfolio utilisent uniquement des données simulées.

---

## Livrables

- [Dossier d'architecture technique - PDF](./DAT_Projet5_Architecture_Integration_Sainte-Marie.pdf)
- [`diagrams/`](./diagrams/) - schémas Draw.io et exports PNG
- [`screenshots/smart-on-fhir/`](./screenshots/smart-on-fhir/) - preuves du POC OAuth2

---

## Continuité du portfolio

- **Projet 1** - Cartographie HL7 v2
- **Projet 2** - Profil FHIR R4 Patient / INS
- **Projet 3** - Serveur HAPI FHIR
- **Projet 4** - IHE XDS.b / MHD
- **Projet 5** - Architecture d'intégration globale

---

**Technologies :** HL7 v2 · FHIR R4 · Mirth Connect · HAPI FHIR · Docker · MLLP · OAuth2 / OIDC · SMART on FHIR · Keycloak · IHE XDS.b / MHD