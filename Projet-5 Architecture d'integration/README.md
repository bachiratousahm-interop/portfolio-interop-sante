# Projet 5 - Architecture d'intégration SI Santé

## Objectif

Ce projet constitue la **synthèse du portfolio Interopérabilité SI Santé** autour du cas fictif de la Clinique Sainte-Marie.

L'objectif est de proposer une trajectoire d'évolution d'un SI hospitalier hétérogène vers une architecture d'intégration plus centralisée, interopérable et sécurisée.

> Cas pédagogique - données et systèmes simulés.

---

## Architecture cible

L'architecture proposée articule :

- **HL7 v2** pour les flux hospitaliers existants ;
- **Mirth Connect** pour l'intégration et les transformations ;
- **FHIR R4 / HAPI FHIR** pour l'exposition des données ;
- **INS** comme identité de référence cible ;
- **IHE XDS.b / MHD** pour la trajectoire documentaire ;
- **OAuth2 / SMART on FHIR** pour la sécurisation des accès.

Le détail des choix d'architecture, ADR et principes de gouvernance est présenté dans le DAT.

---

## POC réalisés

### HL7 v2 vers FHIR

Trois expérimentations ont été réalisées avec Mirth Connect :

| Flux | Résultat FHIR |
|---|---|
| `ADT^A01` | `Patient` |
| `ADT^A01 + PV1` | `Patient + Encounter` |
| `ORU^R01` | `Observation` |

Les applications sources sont simulées par injection de messages HL7 v2 via **netcat / MLLP**.

Le POC couvre notamment la transformation HL7 v2 vers FHIR, les Bundle Transaction, le PUT conditionnel et le diagnostic/rejeu des messages.

---

### OAuth2 / SMART on FHIR

Un POC d'accès au serveur FHIR a été réalisé avec **Keycloak** :

```text
Application / Postman
        |
        v
     Keycloak
        |
        | JWT + scopes SMART
        v
    HAPI FHIR
        |
        v
     HTTP 200
```

L'obtention du token et l'appel FHIR avec Bearer token ont été validés.

L'application effective des scopes comme règles d'autorisation côté HAPI FHIR n'a pas été implémentée dans le POC.

---

## Architecture cible vs POC

Le projet distingue volontairement les éléments **expérimentés** de la cible d'industrialisation.

Non implémentés :

- connexion réelle à Orbis, Sysmex, Sectra ou Génois ;
- enforcement des scopes SMART côté HAPI FHIR ;
- API Gateway industrialisée ;
- connexion réelle à INSi / DMP ;
- infrastructure XDS.b / MHD complète.

---

## Livrables

Le dossier contient :

- `Projet-5 DAT-Architecture-d'integration-Clinique-Sainte-Marie.pdf`
- `diagrams/` - quatre schémas d'architecture et d'intégration
- `Screenshot_smart_on_fhir/` - preuves du POC OAuth2 / SMART on FHIR

Les exports techniques détaillés des canaux Mirth sont conservés dans le dossier Mirth dédié du portfolio.

---

## Continuité du portfolio

```text
Projet 1 - Cartographie HL7 v2
Projet 2 - Profil FHIR R4 Patient / INS
Projet 3 - Serveur HAPI FHIR
Projet 4 - IHE XDS.b / MHD
Projet 5 - Architecture d'intégration globale
```

---

**Technologies et standards :** HL7 v2 · FHIR R4 · Mirth Connect · HAPI FHIR · MLLP · Docker · OAuth2 / OIDC · SMART on FHIR · Keycloak · IHE XDS.b / MHD