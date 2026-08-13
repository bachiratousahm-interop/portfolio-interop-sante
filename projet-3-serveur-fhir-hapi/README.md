# Projet 3: Serveur FHIR R4 - Clinique Sainte-Marie

## Objectif

Déploiement d'un serveur FHIR R4 personnel, peuplement avec des données synthétiques de la Clinique Sainte-Marie, et démonstration des opérations FHIR via une collection Postman documentée.

---

## Serveur FHIR

| Propriété | Valeur |
|---|---|
| **URL de base** | `https://fhir-sainte-marie.up.railway.app/fhir` |
| **Implémentation** | Hapi FHIR 8.8.0 |
| **Version FHIR** | R4 (4.0.1) |
| **Hébergeur** | Railway.app (Europe West 4) |
| **CapabilityStatement** | `GET /fhir/metadata` |

---

## Architecture

```
Postman (client)
    │
    │  requêtes HTTP REST FHIR
    ▼
Hapi FHIR 8.8.0
(conteneur Docker hapiproject/hapi:latest)
    │
    │  tourne sur
    ▼
Railway.app
    │
    │  stocke dans
    ▼
Base de données H2 (embarquée)
```

---

## Ressources créées

L'écosystème suivant a été créé sur le serveur, représentant un cas clinique de cardiologie :

| Ressource | ID | Description |
|---|---|---|
| `Organization` | `clinique-sainte-marie` | Clinique Sainte-Marie, Montpellier |
| `Practitioner` | `dr-martin` | Dr. Pierre MARTIN, cardiologue |
| `Patient` | `patient-jean-dupont` | Jean DUPONT, né 15/03/1968, IPP 00012345 |
| `Encounter` | `encounter-dupont-cardio-01` | Consultation cardiologie du 12/03/2026 |
| `Observation` | `obs-tension-dupont-01` | Tension artérielle 145/92 mmHg |
| `Observation` | `obs-nfs-dupont-01` | Numération Formule Sanguine |
| `DiagnosticReport` | `dr-cardio-dupont-01` | Compte-rendu cardiologique |

### Référentiel patient Jean DUPONT

```json
{
  "resourceType": "Patient",
  "id": "patient-jean-dupont",
  "meta": {
    "profile": [
      "https://clinique-sainte-marie.fr/fhir/StructureDefinition/SteMariePatientINS"
    ]
  },
  "identifier": [
    {
      "type": { "coding": [{ "system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "PI" }] },
      "system": "https://clinique-sainte-marie.fr/fhir/Patient",
      "value": "00012345"
    },
    {
      "type": { "coding": [{ "system": "https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-v2-0203", "code": "INS-NIR" }] },
      "system": "urn:oid:1.2.250.1.213.1.4.8",
      "value": "196803150123456"
    }
  ]
}
```

---

## Collection Postman

### Structure de la collection

```
Clinique Sainte-Marie - FHIR R4
├── CapabilityStatement
│   └── GET — metadata
├── Organization
│   └── PUT — Créer Clinique Sainte-Marie
├── Practitioner
│   └── PUT — Créer Dr. Martin
├── Patient
│   ├── PUT — Créer Jean Dupont
│   ├── GET — Lire Jean Dupont
│   ├── GET — Rechercher par nom
│   └── GET — Dossier complet ($everything)
├── Encounter
│   └── PUT — Consultation cardio 
├── Observation
│   ├── PUT — Tension artérielle
│   ├── PUT — NFS
│   └── GET — Observations Jean Dupont
├── DiagnosticReport
│   ├── PUT — Compte-rendu cardio
│   └── PATCH — Mise à jour conclusion
├── Recherches
│   ├── GET — Patient par nom de famille
│   ├── GET — Observations par patient et code
│   ├── GET — Leucocytes > 5.0 (component search)
│   └── GET — Encounter par patient
├── Transaction
│   └── POST — Bundle transaction (Marie MARTIN)
└── Validation
    └── POST — $validate Patient
```

---

## Opérations FHIR démontrées

### CRUD de base

```
GET    /fhir/Patient/patient-jean-dupont
PUT    /fhir/Patient/patient-jean-dupont
PATCH  /fhir/DiagnosticReport/dr-cardio-dupont-01
DELETE /fhir/StructureDefinition/ste-marie-patient-ins
```

### Choix PUT vs POST pour la création des ressources

Toutes les ressources ont été créées via `PUT` plutôt que `POST` afin de **forcer des IDs métier lisibles** et cohérents avec la documentation :

| Méthode | Comportement | Exemple |
|---|---|---|
| `POST /fhir/Patient` | ID généré aléatoirement par Hapi | `Patient/a3f7b2c1-9d4e...` |
| `PUT /fhir/Patient/patient-jean-dupont` | ID forcé et maîtrisé | `Patient/patient-jean-dupont` |

Ce choix facilite la lisibilité du portfolio et la cohérence des références entre ressources, par exemple `managingOrganization` référence `Organization/clinique-sainte-marie` dont l'ID est explicitement contrôlé.

### Search parameters

```
# Recherche par nom de famille
GET /fhir/Patient?family=DUPONT

# Observations d'un patient filtrées par code LOINC
GET /fhir/Observation?patient=patient-jean-dupont&code=58410-2

# Recherche sur composants (NFS leucocytes > 5.0)
GET /fhir/Observation?component-code=6690-2&component-value-quantity=gt5.0

# Dossier complet patient
GET /fhir/Patient/patient-jean-dupont/$everything

# Bundle transaction
POST /fhir  (Bundle type=transaction)
```

---

## Profil FHIR

Le Patient Jean DUPONT est conforme au profil `SteMariePatientINS` défini dans le Projet 2 :

- **URL canonique** : `https://clinique-sainte-marie.fr/fhir/StructureDefinition/SteMariePatientINS`
- **Publié sur** : [Simplifier.net](https://simplifier.net) , projet`portfolio-sainte-marie`
- **Hiérarchie** : Patient R4 → FrPatient → FrPatientINS → SteMariePatientINS

### Note sur la validation

La validation complète via `$validate` du profil `SteMariePatientINS` nécessite le chargement de l'écosystème FR Core complet et des terminologies ANS (NOS). Cette configuration dépasse les ressources disponibles sur l'environnement de démonstration Railway.

La validation a été réalisée via [validator.fhir.org](https://validator.fhir.org), voir captures dans `/captures`.



## Notes techniques

### Comportement de Hapi FHIR 8.8.0

Au cours de ce projet, plusieurs comportements notables de Hapi FHIR 8.8.0 ont été identifiés et documentés :

**EncounterStatus**: Hapi 8.8.0 utilise les codes STU3 (`finished`, `arrived`, `triaged`...) plutôt que les codes R4 (`completed`...). Ce comportement est hérité de la version STU3 de FHIR et n'a pas été mis à jour pour maintenir la compatibilité ascendante. Le profil FR Core utilise également `finished`, ce qui confirme la convergence entre l'implémentation Hapi et le profil national français.


**Terminologies ANS**: Les CodeSystems de l'ANS (NOS, TRE_R13-CommuneOM...) ne sont pas disponibles sur le serveur de terminologies standard `tx.fhir.org`. Ils sont hébergés sur `smt.esante.gouv.fr` et ne sont pas intégrés dans Hapi sans configuration spécifique.

### Variables d'environnement Railway

| Variable | Valeur |
|---|---|
| `hapi.fhir.fhir_version` | `R4` |
| `hapi.fhir.server_address` | `https://fhir-sainte-marie.up.railway.app/fhir` |
| `hapi.fhir.implementationguides.fr-core.name` | `hl7.fhir.fr.core` |
| `hapi.fhir.implementationguides.fr-core.version` | `2.1.0` |

---

## Liens utiles

| Ressource | URL |
|---|---|
| Serveur FHIR | https://fhir-sainte-marie.up.railway.app/fhir |
| CapabilityStatement | https://fhir-sainte-marie.up.railway.app/fhir/metadata |
| Patient Jean DUPONT | https://fhir-sainte-marie.up.railway.app/fhir/Patient/patient-jean-dupont |
| Profil Simplifier | https://simplifier.net/portfolio-sainte-marie |
| Projet 2 (profils FHIR) | ../projet-2-fhir-r4/ |

---

## Livrables

- [x] Serveur Hapi FHIR R4 déployé sur Railway
- [x] URL publique fonctionnelle
- [x] CapabilityStatement accessible
- [x] 7 ressources FHIR créées (Organization, Practitioner, Patient, Encounter, 2x Observation, DiagnosticReport)
- [x] Collection Postman exportée avec 20+ requêtes documentées
- [x] Search parameters avancés démontrés (component search, $everything, Bundle transaction)
- [x] Comportements Hapi 8.8.0 documentés (EncounterStatus STU3, terminologies ANS, validation)

