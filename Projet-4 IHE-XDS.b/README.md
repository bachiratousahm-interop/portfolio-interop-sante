# Projet 4 — Partage documentaire IHE XDS.b / CI-SIS PDSm

## Clinique Sainte-Marie — Architecture de partage documentaire vers le DMP

Ce projet présente la conception d'une architecture de **partage de documents de santé** pour la Clinique Sainte-Marie, établissement fictif utilisé comme fil conducteur de mon portfolio en interopérabilité SI Santé.

L'objectif est de modéliser un circuit documentaire conforme aux principes **IHE XDS.b** et au cadre français **CI-SIS**, avec :

- publication de comptes rendus médicaux vers le **DMP** ;
- gestion des métadonnées documentaires XDS ;
- recherche et récupération des documents ;
- prise en compte du cas particulier de l'imagerie avec **DRIMbox / DRIM-M et DICOM KOS** ;
- ouverture vers une trajectoire **FHIR R4 / IHE MHD / CI-SIS PDSm**.

> **Projet portfolio fictif :** aucune connexion réelle au DMP, aucune DRIMbox de production et aucune infrastructure XDS certifiée ne sont déployées.

---

## 1. Contexte

La Clinique Sainte-Marie dispose de plusieurs systèmes producteurs de documents :

| Système | Rôle |
|---|---|
| **DPI Orbis** | Comptes rendus de consultation et lettres de sortie |
| **RIS Sectra** | Comptes rendus d'imagerie |
| **PACS Sectra** | Stockage des objets DICOM |
| **LIS Sysmex** | Résultats et comptes rendus biologiques |
| **PFI documentaire** | Contrôles, métadonnées, routage, journalisation et rejeu |
| **DRIMbox Source** | Génération et publication du DICOM KOS |
| **DMP** | Cible nationale de partage documentaire |

L'enjeu est de sortir d'une logique de simple transmission de fichiers pour mettre en place un **partage documentaire structuré, traçable et interopérable**.

---

## 2. Architecture XDS.b

L'architecture repose sur les principaux acteurs IHE XDS.b :

- **Document Source**
- **Document Repository**
- **Document Registry**
- **Document Consumer**

### Transactions utilisées

| Fonction | Transaction IHE |
|---|---|
| Publication d'un document | **ITI-41 — Provide and Register Document Set-b** |
| Enregistrement des métadonnées | **ITI-42 — Register Document Set-b** |
| Recherche de documents | **ITI-18 — Registry Stored Query** |
| Récupération d'un document | **ITI-43 — Retrieve Document Set** |

### Architecture cible

![Architecture XDS.b](diagrams/01-architecture-xdsb.png)

La PFI documentaire contrôle et prépare les documents avant leur publication.  
Le **Repository** conserve les documents tandis que le **Registry** indexe leurs métadonnées.

Un consommateur recherche d'abord les documents dans le Registry via **ITI-18**, puis récupère leur contenu auprès du Repository via **ITI-43**.

---

## 3. Cas d'usage principal — Publication d'un compte rendu

Le scénario nominal étudié concerne un **compte rendu de consultation cardiologique** validé dans le DPI Orbis.

### Flux

```text
Cardiologue
    ↓
DPI Orbis
    ↓
PFI documentaire
    ↓ contrôles + métadonnées XDS
ITI-41
    ↓
DMP
```

La PFI assure notamment :

- contrôle de l'identité patient ;
- contrôle des métadonnées obligatoires ;
- validation des terminologies ;
- construction du `DocumentEntry` ;
- construction du `SubmissionSet` ;
- publication ;
- traitement de l'acquittement ;
- journalisation ;
- retry ou rejeu selon la nature de l'erreur.

![Publication CR vers le DMP](diagrams/02-publication-cr-dmp.png)

---

## 4. Métadonnées documentaires

Le projet distingue notamment les métadonnées portées par le **DocumentEntry** et celles du **SubmissionSet**.

Exemples de données contrôlées :

```text
DocumentEntry
├── patientId
├── sourcePatientId
├── classCode
├── typeCode
├── practiceSettingCode
├── confidentialityCode
├── languageCode
├── mimeType
├── formatCode
├── authorPerson
├── creationTime
└── uniqueId

SubmissionSet
├── patientId
├── sourceId
├── submissionTime
├── contentTypeCode
├── author
└── uniqueId
```

Une règle essentielle est la **cohérence de l'identité patient entre le DocumentEntry et le SubmissionSet**.

---

## 5. Règles de gestion

Quelques règles mises en œuvre dans la spécification :

| ID | Règle |
|---|---|
| `RG-XDS-01` | Le document doit avoir un statut métier autorisant son partage |
| `RG-XDS-02` | L'identité patient doit être exploitable avant émission |
| `RG-XDS-03` | Les patientId du DocumentEntry et du SubmissionSet doivent être cohérents |
| `RG-XDS-04` | Les métadonnées obligatoires doivent être présentes |
| `RG-XDS-05` | Les codes doivent appartenir aux terminologies applicables |
| `RG-XDS-06` | Un uniqueId ne doit pas identifier plusieurs documents différents |
| `RG-XDS-07` | Une erreur fonctionnelle ne déclenche pas de retry automatique illimité |
| `RG-XDS-08` | Chaque publication doit produire une trace exploitable |

---

## 6. Gestion des erreurs et résilience

Les erreurs sont séparées en deux catégories.

### Erreur fonctionnelle

Exemples :

- identité patient insuffisante ;
- métadonnée obligatoire absente ;
- code invalide ;
- incohérence patient ;
- identifiant documentaire déjà utilisé.

Traitement :

```text
Rejet
→ file d'erreur
→ correction
→ rejeu contrôlé
```

### Erreur technique

Exemples :

- timeout ;
- indisponibilité de la cible ;
- erreur réseau ;
- erreur TLS.

Traitement :

```text
Retry borné
→ journalisation
→ alerte
→ file d'erreur si échec persistant
```

Chaque échange peut être suivi grâce à un **correlationId**.

---

## 7. Cas imagerie — DRIMbox / DRIM-M

L'imagerie nécessite de distinguer deux objets différents :

1. le **compte rendu textuel**, produit par le RIS ;
2. le **DICOM KOS**, généré par la DRIMbox Source.

Les images elles-mêmes restent stockées dans le **PACS source**.

### Workflow simplifié

```text
Radiologue
    ↓ validation du CR
RIS Sectra
    ├──────────────→ PFI → ITI-41 → DMP
    │
    └→ DRIMbox Source
            ↓
        C-FIND
            ↓
        PACS Sectra
            ↓
     références DICOM
            ↓
       génération KOS
            ↓
        RAD-68
            ↓
           DMP
```

Le **KOS ne contient pas les images** : il référence les objets DICOM de l'examen.

Dans le scénario :

```text
mimeType   = application/dicom
formatCode = 1.2.840.10008.5.1.4.1.1.88.59
```

![Scénario DRIMbox / KOS](diagrams/03-drimbox-kos.png)

---

## 8. Trajectoire PDSm / FHIR R4

Le projet reste principalement basé sur **XDS.b**.

La partie PDSm présente une **trajectoire d'évolution**, et non une implémentation réellement déployée.

Le CI-SIS PDSm s'appuie sur **IHE MHD et FHIR R4** pour proposer une approche REST du partage documentaire.

### Correspondance des modèles

| Concept documentaire | XDS | PDSm / FHIR R4 |
|---|---|---|
| DocumentEntry | DocumentEntry ebXML | `DocumentReference` |
| SubmissionSet | SubmissionSet ebXML | `List` profilée SubmissionSet |
| Folder | Folder ebXML | `List` profilée Folder |
| Contenu documentaire | Document binaire / MTOM | `Binary` |

### Correspondance fonctionnelle des transactions

| Fonction | XDS.b | MHD / PDSm |
|---|---|---|
| Publication | ITI-41 | ITI-65 — Provide Document Bundle |
| Recherche | ITI-18 | ITI-67 — Find Document References |
| Récupération | ITI-43 | ITI-68 — Retrieve Document |

Cette trajectoire pourrait permettre à terme d'exposer les fonctions documentaires à des **applications consommant des API FHIR/REST**, tout en maintenant les flux XDS nécessaires vers les infrastructures documentaires existantes.

---

## 9. Plan de tests

Le DAT définit plusieurs cas de recette :

| Test | Scénario | Résultat attendu |
|---|---|---|
| `TC-XDS-001` | CR valide | Publication acceptée |
| `TC-XDS-002` | patientId absent | Rejet fonctionnel |
| `TC-XDS-003` | typeCode invalide | Rejet et journalisation |
| `TC-XDS-004` | uniqueId déjà utilisé | Gestion du doublon |
| `TC-XDS-005` | Cible indisponible | Retry puis alerte |
| `TC-XDS-006` | Timeout réseau | Retry puis file d'erreur |
| `TC-XDS-007` | Patient incohérent document / lot | Rejet |
| `TC-XDS-008` | Recherche et récupération | Document retrouvé |
| `TC-DRIM-001` | Examen imagerie valide | KOS généré et publié |
| `TC-DRIM-002` | PACS inaccessible | KOS non publié, erreur tracée |

---

## 10. Livrables

```text
Projet-4-XDS-PDSm/
│
├── README.md
├── DAT_Projet4_XDS_PDSm_Sainte-Marie_v3.0.pdf
│
└── diagrams/
    ├── 01-architecture-xdsb.png
    ├── 02-publication-cr-dmp.png
    └── 03-drimbox-kos.png
```

Le **DAT complet** contient les règles, métadonnées, scénarios, mécanismes de résilience et cas de tests détaillés.

---

## 11. Limites du POC

Ce projet est une **étude d'architecture et de spécification**, et non une plateforme DMP réelle.

Ne sont notamment pas implémentés :

- connexion réelle au DMP ;
- certificats et authentification de production ;
- infrastructure XDS réelle ;
- DRIMbox certifiée ;
- tests d'interopérabilité Gazelle ;
- implémentation réelle de PDSm/MHD ;
- consultation réelle des images via DRIM-M.

Les patients, professionnels, identifiants, OID et endpoints utilisés sont fictifs.

---

## 12. Références

- **ANS — Volet Partage de Documents de Santé**
- **ANS — CI-SIS PDSm**
- **IHE — Cross-Enterprise Document Sharing (XDS.b)**
- **IHE — Mobile access to Health Documents (MHD)**
- **IHE — Comprehensive SubmissionSet**
- **ANS — DRIM-M / Imagerie médicale**
- **ANS — Spécifications DRIMbox**

---

## Compétences mobilisées

`IHE XDS.b` · `CI-SIS` · `DMP` · `PDSm` · `IHE MHD` · `FHIR R4` · `DICOM KOS` · `DRIM-M` · `Architecture d'intégration` · `Mapping de métadonnées` · `Gestion des erreurs` · `Plan de tests`

---

**SAHM Bachiratou**  
*Consultante Interopérabilité SI Santé · Architecture d'intégration*