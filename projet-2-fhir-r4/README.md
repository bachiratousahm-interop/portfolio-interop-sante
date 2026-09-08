# Projet 2 — Profil FHIR Patient INS

## 🎯 Objectif

Ce projet met en œuvre un profil FHIR R4 `SteMariePatientINS` pour la Clinique Sainte-Marie, établissement fictif utilisé dans le cadre de mon portfolio d’interopérabilité SI Santé.

Le profil est dérivé de **FRCorePatientINSProfile v2.1.0** et vise à représenter une identité patient compatible avec le cadre français de l’INS, tout en ajoutant des contraintes propres au contexte de la clinique.

---

## 🏥 Contexte

La Clinique Sainte-Marie souhaite préparer son SI aux échanges de données de santé reposant sur FHIR et aux usages nécessitant une identité patient fiabilisée.

Le profil reprend les contraintes nationales portées par FR Core Patient INS et ajoute uniquement les règles locales nécessaires au fonctionnement de l’établissement.

Profil parent :

`FRCorePatientINSProfile — hl7.fhir.fr.core#2.1.0`

Profil local :

`SteMariePatientINS v1.0.1`

Canonical :

`https://fhir-sainte-marie.up.railway.app/fhir/StructureDefinition/SteMariePatientINS`

---

## 🧩 Contraintes locales

Le profil `SteMariePatientINS` renforce principalement trois éléments :

| Élément | FR Core 2.1.0 | Sainte-Marie | Objectif |
|---|---:|---:|---|
| `Patient.identifier` | `1..*` | `2..*` | Renforcer les exigences d'identification pour les échanges |
| `Patient.identifier[PI]` | `0..*` | `1..1` | Imposer un IPP Sainte-Marie |
| `Patient.managingOrganization` | `0..1` | `1..1` | Rattacher obligatoirement le patient à l'établissement |

Les contraintes nationales relatives à l’INS, aux traits d’identité, au lieu de naissance et à la fiabilité de l’identité restent héritées de `FRCorePatientINSProfile`.

Lorsque `identityStatus = VALI`, l’invariant FR Core `fr-core-1` contrôle notamment la présence d’un identifiant INS prévu par le profil.

---

## 🧪 Instance de référence

Une instance fictive `Patient-jean-dupont.json` a été créée pour tester le profil.

Elle contient notamment :

- un IPP Sainte-Marie ;
- un identifiant `INS-NIR-TEST` ;
- les traits d’identité du patient ;
- le lieu de naissance et son code INSEE ;
- l’extension `identityReliability` ;
- le statut d’identité `VALI` ;
- une référence vers `Organization/clinique-sainte-marie`.

L’utilisation de `INS-NIR-TEST` permet de tester les règles INS sans utiliser de donnée patient réelle.

---

## ⚙️ Génération du profil

Le profil est écrit en **FHIR Shorthand (FSH)**.

La `StructureDefinition` est générée localement avec **SUSHI v3.20.0** :

```bash
npx sushi build --snapshot