# Projet 3 — Déploiement et exploitation d’un serveur HAPI FHIR R4

> **HAPI FHIR 8.8.0 · FHIR R4 · Railway · FR Core · Postman · LOINC · UCUM**

## 1. Contexte

Ce projet s’inscrit dans le portfolio d’interopérabilité de la **Clinique Sainte-Marie**, établissement de santé fictif utilisé comme fil conducteur pour plusieurs cas d’usage SI santé.

Après la conception d’un profil Patient INS dans le **Projet 2**, l’objectif de ce projet est de mettre en œuvre un **serveur FHIR opérationnel**, d’y charger des ressources de santé liées entre elles et de tester les principales interactions de l’API REST FHIR.

Le serveur utilisé est **HAPI FHIR R4**, déployé sur **Railway** et accessible en HTTPS.

```text
https://fhir-sainte-marie.up.railway.app/fhir
```

Toutes les données utilisées dans ce projet sont fictives et destinées exclusivement à la démonstration technique.

---

## 2. Objectifs

Ce POC a pour objectifs de mettre en pratique :

- le déploiement et l’exploitation d’un serveur **HAPI FHIR R4** ;
- la manipulation de ressources via l’API REST FHIR ;
- les interactions `GET`, `PUT`, `POST` et `PATCH` ;
- les recherches FHIR paramétrées ;
- la gestion de références entre ressources ;
- l’utilisation d’un `StructureDefinition` local ;
- la validation d’une instance contre un profil FHIR ;
- la validation terminologique avec `$validate-code` ;
- l’utilisation de terminologies cliniques **LOINC** et **UCUM** ;
- l’opération `$everything` ;
- l’utilisation d’un `Bundle` de type `transaction`.

---

## 3. Architecture du POC

```text
┌──────────────────────┐
│       Postman        │
└──────────┬───────────┘
           │
           │ HTTPS / FHIR REST
           ▼
┌──────────────────────┐
│      HAPI FHIR       │
│       FHIR R4        │
└──────────┬───────────┘
           │
           ├── Patient
           ├── Organization
           ├── Practitioner
           ├── Encounter
           ├── Observation
           ├── DiagnosticReport
           ├── StructureDefinition
           └── Bundle
           
       Hébergement
           │
           ▼
        Railway
```

Les tests sont réalisés avec **Postman** à partir d’une collection dédiée au projet.

---

## 4. Jeu de ressources FHIR

Le POC représente un parcours clinique simple autour d’un patient suivi en cardiologie.

Les principales ressources sont :

| Ressource | Utilisation |
|---|---|
| `Patient` | Identité du patient et identifiants |
| `Organization` | Clinique Sainte-Marie |
| `Practitioner` | Médecin intervenant dans la prise en charge |
| `Encounter` | Consultation de cardiologie |
| `Observation` | Mesures cliniques et résultats biologiques |
| `DiagnosticReport` | Compte-rendu clinique |
| `StructureDefinition` | Profil local `SteMariePatientINS` |
| `Bundle` | Transaction multi-ressources |

Les ressources sont liées par des références FHIR.

```text
Organization
     ▲
     │ managingOrganization
     │
   Patient
     │
     │ subject
     ▼
  Encounter ───────────────► Practitioner
     │                         participant
     │
     ├─────────────► Observation TA
     │
     ├─────────────► Observation NFS
     │
     ▼
DiagnosticReport
```

Exemple de référence :

```json
"subject": {
  "reference": "Patient/patient-jean-dupont"
}
```

Les ressources référencées dans le scénario ont été créées et vérifiées sur le serveur.

---

## 5. Interactions REST FHIR

### 5.1 CapabilityStatement

Le `CapabilityStatement` permet de vérifier que le serveur est disponible et d’identifier les capacités FHIR qu’il expose.

```http
GET {{base_url}}/metadata
```

---

### 5.2 Création et mise à jour avec PUT

Les ressources du POC possédant un identifiant déterminé sont créées avec `PUT`.

Exemples :

```http
PUT {{base_url}}/Patient/patient-jean-dupont
```

```http
PUT {{base_url}}/Practitioner/dr-martin
```

```http
PUT {{base_url}}/Encounter/encounter-dupont-cardio-01
```

```http
PUT {{base_url}}/Observation/obs-tension-dupont-01
```

Avec cette interaction, une ressource inexistante peut être créée et une ressource existante mise à jour avec le même identifiant.

---

### 5.3 Lecture d’une ressource

Exemple de lecture directe par identifiant :

```http
GET {{base_url}}/Patient/patient-jean-dupont
```

```http
GET {{base_url}}/Practitioner/dr-martin
```

```http
GET {{base_url}}/Encounter/encounter-dupont-cardio-01
```

---

## 6. Recherches FHIR

Plusieurs recherches paramétrées ont été testées.

### Recherche d’un Patient par nom

```http
GET {{base_url}}/Patient?family=DUPONT
```

### Recherche des Observations d’un Patient

```http
GET {{base_url}}/Observation?patient=patient-jean-dupont
```

### Recherche d’une Observation par code

```http
GET {{base_url}}/Observation?patient=patient-jean-dupont&code=58410-2
```

### Recherche par catégorie

```http
GET {{base_url}}/Observation?patient=patient-jean-dupont&category=laboratory
```

### Recherche sur un composant d’Observation

```http
GET {{base_url}}/Observation?component-code=6690-2&component-value-quantity=gt5.0
```

Ce dernier exemple combine :

- un code de composant ;
- une comparaison sur une valeur quantitative.

---

## 7. Opération Patient `$everything`

L’opération suivante a également été testée :

```http
GET {{base_url}}/Patient/patient-jean-dupont/$everything
```

Elle permet d’interroger les ressources associées au contexte d’un Patient selon les capacités proposées par le serveur.

---

## 8. Utilisation du profil `SteMariePatientINS`

Le Projet 2 a permis de concevoir un profil Patient spécifique à la Clinique Sainte-Marie :

```text
SteMariePatientINS
```

Ce profil dérive de :

```text
FRCorePatientINS
```

La conception FSH et le détail des contraintes du profil sont documentés dans le **Projet 2 — Profil FHIR R4 Patient INS**.

Dans le Projet 3, le `StructureDefinition` est chargé sur HAPI FHIR afin d’être exploité par le moteur de validation.

Canonical utilisé :

```text
https://fhir-sainte-marie.up.railway.app/fhir/StructureDefinition/SteMariePatientINS
```

Recherche du profil :

```http
GET {{base_url}}/StructureDefinition?url={{profileSteMarie}}
```

Le profil peut également être lu directement par son identifiant :

```http
GET {{base_url}}/StructureDefinition/SteMariePatientINS
```

---

## 9. Validation du Patient

L’instance Patient est soumise explicitement au profil local avec l’opération `$validate`.

```http
POST {{base_url}}/Patient/$validate?profile={{profileSteMarie}}
```

Le Patient déclare également le profil dans `meta.profile`.

```json
"meta": {
  "profile": [
    "https://fhir-sainte-marie.up.railway.app/fhir/StructureDefinition/SteMariePatientINS"
  ]
}
```

La validation obtenue ne comporte aucune issue de sévérité :

```text
fatal
```

ou :

```text
error
```

Le validator retourne cependant quelques warnings et messages d’information non bloquants, notamment autour :

- du binding générique FHIR R4 de `Identifier.type` ;
- du traitement de certaines terminologies FR Core ;
- du slicing hérité de FR Core.

Ces résultats ont été analysés séparément afin de distinguer les problèmes de conformité des avertissements propres au moteur de validation.

---

## 10. Validation terminologique INS

La reconnaissance du code INS a été vérifiée directement avec l’opération :

```http
GET {{base_url}}/CodeSystem/$validate-code
```

Requête utilisée :

```http
GET {{base_url}}/CodeSystem/$validate-code?url=https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-v2-0203&code=INS-NIR-TEST
```

Résultat :

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "result",
      "valueBoolean": true
    },
    {
      "name": "display",
      "valueString": "NIR TEST"
    }
  ]
}
```

Le résultat confirme que le moteur terminologique reconnaît :

```text
Code    : INS-NIR-TEST
Display : NIR TEST
```

---

## 11. Observation clinique — pression artérielle

Une ressource `Observation` représente une mesure de pression artérielle :

```text
145 / 92 mmHg
```

Elle est associée :

- au Patient ;
- à la consultation ;
- au Practitioner ayant réalisé la mesure.

Extrait :

```json
"subject": {
  "reference": "Patient/patient-jean-dupont"
},
"encounter": {
  "reference": "Encounter/encounter-dupont-cardio-01"
},
"performer": [
  {
    "reference": "Practitioner/dr-martin"
  }
]
```

### Terminologies utilisées

| Donnée | Terminologie | Code |
|---|---|---|
| Panel de pression artérielle | LOINC | `85354-9` |
| Pression systolique | LOINC | `8480-6` |
| Pression diastolique | LOINC | `8462-4` |
| Unité de pression | UCUM | `mm[Hg]` |

Exemple :

```json
{
  "system": "http://loinc.org",
  "code": "8480-6",
  "display": "Systolic blood pressure"
}
```

Valeur :

```json
"valueQuantity": {
  "value": 145,
  "unit": "mmHg",
  "system": "http://unitsofmeasure.org",
  "code": "mm[Hg]"
}
```

---

## 12. Validation de l’Observation

L’Observation est validée avec :

```http
POST {{base_url}}/Observation/$validate
```

Résultat final :

```json
{
  "resourceType": "OperationOutcome",
  "issue": [
    {
      "severity": "information",
      "code": "informational",
      "diagnostics": "No issues detected during validation"
    }
  ]
}
```

Le résultat final est donc :

```text
0 fatal
0 error
0 warning
```

Cette validation permet notamment de vérifier la cohérence structurelle de l’Observation et l’utilisation des codifications LOINC et UCUM présentes dans la ressource.

---

## 13. Observation biologique

Une seconde `Observation` représente une **Numération Formule Sanguine (NFS)**.

Elle permet de manipuler plusieurs composants biologiques dans une même ressource :

| Élément | Code LOINC |
|---|---|
| NFS | `58410-2` |
| Leucocytes | `6690-2` |
| Érythrocytes | `789-8` |
| Hémoglobine | `718-7` |
| Plaquettes | `777-3` |

Les valeurs quantitatives utilisent des unités UCUM telles que :

```text
10*9/L
10*12/L
g/dL
```

Cette ressource est également utilisée pour tester les recherches FHIR sur :

- le Patient ;
- le code de l’Observation ;
- la catégorie `laboratory` ;
- les composants et valeurs quantitatives.

---

## 14. DiagnosticReport et PATCH

Un `DiagnosticReport` est utilisé pour représenter un compte-rendu de consultation cardiologique.

Il référence notamment :

```text
Patient
Encounter
Practitioner
Observation
```

Une mise à jour partielle de sa conclusion est réalisée avec **JSON Patch**.

```http
PATCH {{base_url}}/DiagnosticReport/dr-cardio-dupont-01
Content-Type: application/json-patch+json
```

Exemple :

```json
[
  {
    "op": "replace",
    "path": "/conclusion",
    "value": "Patient hypertendu. TA 145/92 mmHg. Mise sous Amlodipine 5mg/j. Contrôle ECG et bilan lipidique dans 3 mois."
  }
]
```

Cette opération permet de modifier uniquement l’élément ciblé sans renvoyer la totalité de la ressource.

---

## 15. Bundle transaction

Un `Bundle` FHIR de type `transaction` est utilisé pour envoyer plusieurs opérations dans une seule requête.

```json
{
  "resourceType": "Bundle",
  "type": "transaction"
}
```

Le scénario comprend :

```text
Patient/patient-marie-martin
          │
          ▼
Encounter/encounter-martin-cardio-01
```

Chaque entrée contient une instruction HTTP :

```json
"request": {
  "method": "PUT",
  "url": "Patient/patient-marie-martin"
}
```

et :

```json
"request": {
  "method": "PUT",
  "url": "Encounter/encounter-martin-cardio-01"
}
```

Lors de la première exécution, une ressource inexistante peut être créée avec un statut :

```text
201 Created
```

Si le même identifiant existe déjà, le `PUT` permet de mettre à jour la ressource.

Le `Bundle` de type `transaction` permet de traiter plusieurs opérations comme une unité transactionnelle.

---

## 16. Collection Postman

Une collection Postman est fournie avec le projet afin de reproduire les principaux tests.

Elle contient notamment :

```text
GET    /metadata

PUT    /Patient/{id}
GET    /Patient/{id}
GET    /Patient?family=...
GET    /Patient/{id}/$everything
POST   /Patient/$validate

PUT    /Organization/{id}

PUT    /Practitioner/{id}
GET    /Practitioner/{id}

PUT    /Encounter/{id}
GET    /Encounter/{id}

PUT    /Observation/{id}
GET    /Observation?patient=...
GET    /Observation?...&code=...
GET    /Observation?...&category=...
POST   /Observation/$validate

PUT    /DiagnosticReport/{id}
PATCH  /DiagnosticReport/{id}

POST   /        # Bundle transaction

PUT    /StructureDefinition/{id}
GET    /StructureDefinition?url=...

GET    /CodeSystem/$validate-code
```

Variables principales utilisées dans Postman :

```text
{{base_url}}
{{profileSteMarie}}
```

---

## 17. Preuves techniques

Le dossier `evidence/` contient les principales preuves issues des tests Postman.

Exemples :

```text
GET-capabilitystatement.png
POST-bundle-transaction.png
validate-instance-patient.png
validate-observation.png
validate-code-INS-NIR-TEST.png
```

Les captures permettent d’accéder rapidement aux résultats importants sans dupliquer l’ensemble des réponses HAPI FHIR dans le README.

---

## 18. Structure du projet

```text
projet-3-serveur-fhir-hapi/
│
├── README.md
│
├── bundle/
│   └── Bundle-transaction-sainte-marie.json
│
├── evidence/
│   ├── GET-capabilitystatement.png
│   ├── POST-bundle-transaction.png
│   ├── validate-instance-patient.png
│   ├── validate-observation.png
│   └── validate-code-INS-NIR-TEST.png
│
├── instances/
│   ├── DiagnosticReport-compte-rendu-consultation.json
│   ├── Encounter-dupont.json
│   ├── Observation-NFS-dupont.json
│   ├── Observation-tension-dupont.json
│   ├── Organisation-sainte-marie.json
│   ├── patient-jean-dupont.json
│   └── Practitioner-pierre-martin.json
│
└── postman/
    └── Clinique-sainte-Marie-FHIR-R4.postman_collection.json
```

---

## 19. Résultats

Le POC permet de démontrer :

- le déploiement d’un serveur HAPI FHIR R4 accessible en HTTPS ;
- l’utilisation des principales interactions REST FHIR ;
- la création d’un jeu cohérent de ressources de santé ;
- la navigation entre ressources via les références FHIR ;
- l’utilisation des recherches paramétrées ;
- l’utilisation de `$everything` ;
- le chargement et l’exploitation d’un `StructureDefinition` local ;
- la validation d’un Patient contre un profil dérivé de FR Core ;
- la validation terminologique d’un code INS ;
- l’utilisation de LOINC et UCUM ;
- la validation complète d’une Observation clinique ;
- la mise à jour partielle d’une ressource avec JSON Patch ;
- l’utilisation d’un Bundle transactionnel.

---

## 20. Limites du POC

Ce projet constitue un **POC technique** et non une architecture de production.

La configuration actuelle a été volontairement dimensionnée pour un environnement de démonstration.

Elle ne couvre pas notamment :

- la haute disponibilité ;
- la stratégie complète de sauvegarde et restauration ;
- la supervision de production ;
- le dimensionnement pour des volumes hospitaliers réels ;
- la persistance de niveau production ;
- les exigences réglementaires d’un hébergement réel de données de santé.

Le stockage utilisé dans ce POC repose sur une configuration légère afin de limiter la consommation de ressources sur Railway.

La sécurité OAuth2 / SMART on FHIR, l’intégration avec l’ESB et l’architecture globale du SI sont abordées dans d’autres projets du portfolio.

---

## 21. Compétences mises en œuvre

**Standards et interopérabilité**

```text
FHIR R4
FR Core
INS
LOINC
UCUM
```

**API et opérations FHIR**

```text
FHIR REST API
GET / PUT / POST / PATCH
FHIR Search
$everything
$validate
$validate-code
Bundle Transaction
JSON Patch
```

**Outils et environnement**

```text
HAPI FHIR
Postman
Railway
JSON
Git
GitHub
```

---

## Liens avec les autres projets du portfolio

- **Projet 2** — conception et validation du profil FHIR Patient INS ;
- **Projet 4** — partage documentaire IHE XDS.b / MHD ;
- **Projet 5** — architecture globale d’intégration, ESB et sécurité.

---

**SAHM Bachiratou**  
*Consultante Interopérabilité SI Santé & Architecture d’intégration*