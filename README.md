# Portfolio - Interopérabilité SI Santé

**HL7 v2 · FHIR R4 · FR Core · IHE XDS.b / MHD · Mirth Connect · HAPI FHIR · SMART on FHIR**

Portfolio technique consacré à l'**interopérabilité des systèmes d'information de santé** et à l'**architecture d'intégration**.

Les différents projets s'appuient sur un même cas pédagogique : la **Clinique Sainte-Marie**, établissement fictif utilisé pour construire progressivement une architecture hospitalière allant des flux HL7 v2 existants jusqu'à une cible FHIR et documentaire sécurisée.

> Toutes les données, identités, établissements et systèmes utilisés dans les démonstrations sont fictifs ou simulés.

---

## Projets

| Projet | Sujet | Principaux éléments |
|---|---|---|
| [Projet 1](./projet-1-cartographie-hl7v2/) | **Cartographie HL7 v2** | Flux hospitaliers, MLLP, routage, règles d'interface |
| [Projet 2](./projet-2-fhir-r4/) | **Profil FHIR R4 Patient / INS** | FR Core, FSH, SUSHI, StructureDefinition, validation |
| [Projet 3](./projet-3-serveur-fhir-hapi/) | **Serveur HAPI FHIR R4** | API REST, ressources FHIR, validation, terminologies, Bundle |
| [[Projet 4](./Projet-4%20IHE-XDS.b/) | **Partage documentaire XDS.b / MHD** | DMP, CI-SIS, PDSm, DRIMbox, DICOM KOS |
| [Projet 5](./Projet-5%20Architecture%20d%27integration/) | **Architecture d'intégration globale** | HL7 v2 → FHIR, Mirth, SMART on FHIR, architecture cible |

### Artefacts Mirth Connect

Le dossier [Mirth-channels](./Mirth-channels/) contient les exports et preuves techniques des canaux utilisés pour expérimenter les transformations **HL7 v2 vers FHIR R4**.

---

## Progression du portfolio

```text
HL7 v2
   |
   v
Cartographie des flux
   |
   v
Profil FHIR Patient / INS
   |
   v
Serveur HAPI FHIR
   |
   v
Partage documentaire XDS.b / MHD
   |
   v
Architecture d'intégration globale
```

Le **Projet 5** constitue la synthèse de cette progression et distingue les éléments réellement expérimentés de l'architecture cible proposée.

---

## Standards et outils

**Interopérabilité**

`HL7 v2` · `FHIR R4` · `FR Core` · `IHE XDS.b` · `IHE MHD` · `CI-SIS` · `DICOM`

**Intégration et API**

`Mirth Connect` · `HAPI FHIR` · `MLLP` · `REST` · `Postman`

**Sécurité et infrastructure**

`OAuth2 / OIDC` · `SMART on FHIR` · `Keycloak` · `Docker`

**Modélisation FHIR**

`FSH` · `SUSHI` · `LOINC` · `UCUM`

---

## Positionnement

Ce portfolio illustre une démarche orientée :

- analyse et cartographie des flux d'interopérabilité ;
- spécification d'interfaces ;
- mapping HL7 v2 / FHIR ;
- configuration et diagnostic de flux d'intégration ;
- conception d'architectures d'intégration SI Santé ;
- compréhension des enjeux d'identité, de partage documentaire et de sécurisation des API.

**Positionnement : Consultante Interopérabilité SI Santé / Architecture d'intégration**
