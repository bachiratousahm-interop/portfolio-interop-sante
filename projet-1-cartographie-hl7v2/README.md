
# Projet 1: Cartographie des flux HL7 v2

## Contexte

La Clinique Sainte-Marie est un établissement fictif de 180 lits disposant de plusieurs applications métier : DPI Orbis, Mirth Connect, LIS Sysmex, RIS/PACS Sectra, PUI Génois et SIC Hemera.

L’objectif du projet est de cartographier et spécifier les principaux échanges HL7 v2.5 de l’existant avant une évolution progressive vers une architecture FHIR.

## Objectifs

- Identifier les systèmes producteurs et consommateurs de données.
- Cartographier les flux ADT, ORM, ORU, OMP et RDS.
- Formaliser les règles de routage dans Mirth Connect.
- Définir les règles de corrélation patient, séjour et prescription.
- Préparer les cas de recette des interfaces.

## Architecture

L’architecture repose sur un modèle hub-and-spoke dans lequel Mirth Connect assure la réception, le contrôle, la transformation et le routage des messages HL7 v2.

## Principaux flux

| Domaine | Message | Source | Destination |
|---|---|---|---|
| Admission | ADT^A01 | DPI | LIS, RIS, PACS, PUI, SIC conditionnel |
| Biologie | ORM^O01 | DPI | LIS |
| Résultat biologique | ORU^R01 | LIS | DPI |
| Imagerie | ORM^O01 | DPI | RIS |
| Cardiologie | ORM^O01 | DPI | SIC |
| Prescription médicament | OMP^O09 | SIC puis DPI | DPI puis PUI |
| Dispensation | RDS^O13 | PUI | DPI |
| Sortie | ADT^A03 | DPI | Applications abonnées |

## Circuit du médicament

Dans le scénario retenu, une prescription peut être initiée dans le SIC Hemera puis intégrée dans le DPI Orbis avant transmission à la PUI Génois.

Le DPI constitue le point central de traçabilité de la prescription dans le dossier patient.

## Contrôles principaux

Les contrôles portent notamment sur :

- `PID-3` : identification patient ;
- `PV1-19` : rattachement au séjour ;
- `MSH-9` : type de message ;
- `MSH-10` : unicité et détection des doublons ;
- `ORC-2`, `OBR-2`, `OBR-3` : corrélation demande–résultat ;
- `OBR-4` : contrôle du code métier ;
- `MSA-1`, `MSA-2` : gestion des ACK.

## Tests de recette

Le projet couvre des cas nominaux et d’erreur : admission CARDIO, absence de PV1-19, résultat non corrélé, code métier inconnu, ACK en erreur et détection de doublons.

## Livrables
Le dossier contient :
- le DAT au format PDF 
- les diagrammes d’architecture et de flux HL7 v2.

## Technologies et standards

- HL7 v2.5
- Mirth Connect
- MLLP
- DICOM
- Orbis
- Sysmex
- Sectra
- Génois
- Hemera

## Limites du périmètre

Le projet 1 décrit l’architecture existante HL7 v2. La transformation vers FHIR R4, le serveur HAPI FHIR, IHE XDS.b/MHD, l’API Management et la sécurité sont traités dans les projets suivants du portfolio.