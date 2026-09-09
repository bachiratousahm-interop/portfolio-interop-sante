# Projet 2 - Profil FHIR R4 Patient INS

## Objectif

Ce projet met en œuvre un profil FHIR R4 `SteMariePatientINS` pour la Clinique Sainte-Marie, établissement fictif utilisé comme fil conducteur du portfolio.

Le profil dérive de **FR Core Patient INS 2.1.0** et ajoute des contraintes locales permettant d'expérimenter la représentation d'une identité patient dans un contexte français.

> Cas pédagogique - aucune donnée patient réelle n'est utilisée.

---

## Profil réalisé

Profil parent :

`FRCorePatientINSProfile - hl7.fhir.fr.core#2.1.0`

Profil local :

`SteMariePatientINS v1.0.1`

Le profil ajoute notamment :

| Élément | Contrainte locale |
|---|---|
| `Patient.identifier` | `2..*` |
| `Patient.identifier[PI]` | `1..1` |
| `Patient.managingOrganization` | `1..1` |

L'objectif est notamment d'associer une identité INS de test à un IPP local Sainte-Marie.

---

## Implémentation

Le profil est écrit en **FHIR Shorthand (FSH)** puis généré avec **SUSHI**.

```bash
npx sushi build --snapshot
```

Les principaux artefacts du projet sont :

- `SteMariePatientINS.fsh` - définition FSH du profil ;
- `StructureDefinition-SteMariePatientINS.json` - StructureDefinition générée ;
- `Patient-jean-dupont.json` - instance Patient fictive de test ;
- `SPEC-FHIR-Patient-SteMariePatientINS.pdf` - spécification du profil ;
- `Screenshot/` - captures des étapes de génération et de validation.

---

## Instance de test

L'instance fictive `Patient-jean-dupont.json` contient notamment :

- un IPP Sainte-Marie ;
- un identifiant `INS-NIR-TEST` ;
- les traits d'identité ;
- le lieu de naissance ;
- le statut d'identité ;
- une référence vers l'organisation Sainte-Marie.

`INS-NIR-TEST` est utilisé uniquement à des fins de démonstration.

---

## Validation

Le profil et l'instance ont été utilisés pour expérimenter :

- la génération d'une `StructureDefinition` avec SUSHI ;
- la validation d'une ressource Patient ;
- les contraintes héritées de FR Core ;
- les contraintes locales du profil Sainte-Marie.

Les tests serveur et les opérations FHIR associées sont poursuivis dans le **Projet 3 - Serveur HAPI FHIR**.

---

## Livrables

Le dossier contient :

- la spécification PDF ;
- le fichier FSH ;
- la StructureDefinition JSON ;
- l'instance Patient de test ;
- les screenshot de génération et de validation.

---

**Technologies :** FHIR R4 · FR Core · FSH · SUSHI · INS