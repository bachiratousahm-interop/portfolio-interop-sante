# Projet 3 - Serveur HAPI FHIR R4

## Objectif

Ce projet met en œuvre un **serveur HAPI FHIR R4** pour la Clinique Sainte-Marie, établissement fictif utilisé comme fil conducteur du portfolio.

Après la conception du profil Patient INS dans le Projet 2, l'objectif est de manipuler concrètement des ressources FHIR, tester les principales interactions REST et valider un petit parcours clinique cohérent.

> Cas pédagogique - toutes les données utilisées sont fictives.

---

## Architecture du POC

```text
Postman
   |
   | HTTPS / FHIR REST API
   v
HAPI FHIR R4
   |
   +-- Patient
   +-- Organization
   +-- Practitioner
   +-- Encounter
   +-- Observation
   +-- DiagnosticReport
   +-- Bundle

Hébergement : Railway
```

---

## Ressources et opérations testées

Le scénario représente un patient suivi en cardiologie.

Ressources principales :

- `Patient`
- `Organization`
- `Practitioner`
- `Encounter`
- `Observation`
- `DiagnosticReport`
- `StructureDefinition`
- `Bundle`

Interactions expérimentées :

```text
GET
PUT
POST
PATCH
FHIR Search
$everything
$validate
$validate-code
Bundle Transaction
```

---

## Validation et terminologies

Le profil `SteMariePatientINS`, conçu dans le Projet 2, a été chargé sur HAPI FHIR puis utilisé pour valider une instance Patient.

Une `Observation` de pression artérielle a également été créée et validée avec :

- LOINC `85354-9` pour le panel de pression artérielle ;
- LOINC `8480-6` pour la pression systolique ;
- LOINC `8462-4` pour la pression diastolique ;
- UCUM `mm[Hg]` pour l'unité.

La validation de l'Observation a retourné :

```text
No issues detected during validation
```

Une opération `$validate-code` a également été testée pour le code `INS-NIR-TEST`.

---

## Bundle transaction

Un `Bundle` de type `transaction` a été utilisé pour créer plusieurs ressources liées dans une même requête, notamment :

```text
Patient
   |
   v
Encounter
```

Cette expérimentation permet de manipuler une transaction FHIR multi-ressources.

---

## Preuves techniques

Le dossier `evidence/` contient les principales captures issues des tests Postman :

```text
GET-capabilitystatement.png
GET-resultat.png
POST-bundle-transaction.png
validate-instance-patient.png
validate-observation.png
```

Le dossier `postman/` contient la collection et l'environnement utilisés pour reproduire les tests.

---

## Limites du POC

Ce projet constitue un **POC technique** et non une infrastructure de production.

Non couverts :

- haute disponibilité ;
- supervision de production ;
- persistance de niveau production ;
- hébergement réglementaire de données de santé réelles ;
- sécurité OAuth2 / SMART on FHIR.


---

## Livrables

Le dossier contient :

- les instances FHIR JSON ;
- le Bundle transactionnel ;
- la collection Postman ;
- les preuves visuelles des tests.

---

**Technologies :** FHIR R4 · HAPI FHIR 8.8.0 · FR Core · Postman · Railway · LOINC · UCUM · JSON Patch · Bundle Transaction