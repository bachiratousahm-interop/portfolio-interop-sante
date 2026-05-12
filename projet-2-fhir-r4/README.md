
# Projet 2 : Profil FHIR R4 Patient conforme ANS/CI-SIS

## Objectif

Création d'un profil FHIR R4 Patient **SteMariePatientINS** pour la Clinique 
Sainte-Marie, conforme au cadre réglementaire français (INS, CI-SIS, FR Core v2.1.0).

## Standards et référentiels

| Standard | Version | Rôle |
|----------|---------|------|
| HL7 FHIR R4 | 4.0.1 | Socle technique |
| FR Core Interop'Santé | 2.1.0 | Profil parent FrPatientINS |
| Référentiel INS-ANS | - | Obligation réglementaire |
| CI-SIS - ANS | - | Cadre normatif général |

---

## Architecture du profil

Patient FHIR R4 base

└── FrPatient (Interop'Santé)

└── FrPatientINS (Interop'Santé)

└── SteMariePatientINS ← notre profil
### Contraintes ajoutées

| Élément | Cardinalité | Justification |
|---------|-------------|---------------|
| identifier | 2..* | IPP + INS-NIR minimum |
| identifier:IPP | 1..1 | Identifiant local obligatoire |
| name.family | 1..1 | Trait INS |
| name.given | 1..* | Trait INS |
| birthDate | 1..1 | Trait INS |
| gender | 1..1 | Trait INS |
| managingOrganization | 1..1 | Contrainte établissement |

---

## Fichiers

| Fichier | Description |
|---------|-------------|
| `SteMariePatientINS.fsh` | Source FSH du profil |
| `StructureDefinition-SteMariePatientINS.json` | Artefact JSON généré via FSH Online |
| `Patient-jean-dupont.json` | Instance de référence  patient fictif |
| `DAT-SPEC-FHIR-Patient-SteMariePatientINS` | Dossier d'Architecture Technique et Spécification |
| `captures/` | Differential Table + Snapshot Table (Simplifier) |

---

## Profil publié

🔗 [Voir sur Simplifier](https://simplifier.net/portfolio-sainte-marie)

**URL canonique** : https://clinique-sainte-marie.fr/fhir/StructureDefinition/SteMariePatientINS

---

## Validation

Validation réalisée sur [validator.fhir.org](https://validator.fhir.org) 
avec le package `hl7.fhir.fr.core#2.1.0`.

| Niveau | Message | Analyse |
|--------|---------|---------|
| Warning | dom-6 narrative absent | Best practice , non bloquant |
| Warning | Profile not found (domaine fictif) | Attendu , établissement fictif |
| Information | fr-core-cs-v2-0445 is draft | CodeSystem ANS en draft , non bloquant |

**Aucune erreur bloquante.**

## Outils utilisés

- [FSH Online](https://fshschool.org/FSHOnline) — compilation FSH → JSON
- [Simplifier.net](https://simplifier.net) — publication et visualisation
- [validator.fhir.org](https://validator.fhir.org) — validation de l'instance