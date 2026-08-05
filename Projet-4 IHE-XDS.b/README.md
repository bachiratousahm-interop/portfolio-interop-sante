# Projet 4 — Partage documentaire via IHE XDS.b et DMP

> **Portfolio Interopérabilité SI Santé** · Clinique Sainte-Marie (fictif) · 2026

[![IHE XDS.b](https://img.shields.io/badge/IHE-XDS.b-blue)]()
[![CI-SIS](https://img.shields.io/badge/CI--SIS-ANS-green)]()
[![DRIM-M](https://img.shields.io/badge/DRIM--M-ANS-orange)]()
[![Statut](https://img.shields.io/badge/Statut-Terminé-brightgreen)]()

---

## 1. Contexte

**Type d'organisation**
Clinique privée de 180 lits, spécialisée en cardiologie, Montpellier. L'établissement dispose d'une cartographie HL7 v2 (Projet 1), d'un profil FHIR Patient conforme INS (Projet 2) et d'un serveur FHIR R4 opérationnel (Projet 3). L'étape suivante est le partage externe — rendre les documents médicaux produits accessibles au médecin libéral, au patient via Mon Espace Santé, et à tout professionnel de santé autorisé, via le DMP national.

**Problème rencontré**
La clinique produit chaque jour des dizaines de documents médicaux — comptes-rendus de consultation, résultats de biologie, CR d'imagerie, lettres de sortie. Ces documents restent cloisonnés dans les systèmes locaux (Orbis, Sectra, Sysmex). Quand Jean DUPONT consulte son cardiologue libéral après une hospitalisation, ce médecin n'a accès à aucun document produit pendant le séjour — sauf si le patient les apporte physiquement. Cette rupture de continuité est un risque clinique direct et une non-conformité aux obligations de partage documentaire du Ségur du Numérique en Santé.

**Enjeu métier**
Le partage documentaire via le DMP n'est pas une option — c'est une obligation réglementaire (Ségur du Numérique, loi Ma Santé 2022). Pour la clinique, c'est aussi un enjeu de qualité des soins : un cardiologue libéral qui accède au CR d'hospitalisation avant la consultation de suivi prend de meilleures décisions cliniques. Pour les équipes SI, c'est la démonstration que les standards HL7, FHIR et IHE convergent vers un objectif commun.

**Contraintes principales**
- Conformité obligatoire au profil IHE XDS.b et au CI-SIS (ANS)
- INS-NIR obligatoire comme identifiant patient pivot — l'IPP local ne suffit pas pour le DMP
- Métadonnées XDSDocumentEntry conformes aux JDV ANS publiés sur le SMT
- Authentification via VIHF (certificat CPS) pour tout accès DMP
- Spécificité imagerie : la DRIMbox impose un formatCode distinct (`urn:ihe:rad:TEXT`) et un repositoryUniqueId propre dans le cadre DRIM-M

---

## 2. Objectif

**Ce que le projet devait résoudre**
Documenter et simuler l'architecture complète de partage documentaire XDS.b pour la Clinique Sainte-Marie — en détaillant deux cas d'usage représentatifs (flux nominal et flux imagerie DRIMbox/DRIM-M) — en conformité avec le CI-SIS et les JDV ANS.

**La valeur attendue**
- Continuité documentaire garantie : tout document validé par un professionnel est publié au DMP et accessible aux professionnels autorisés
- Conformité Ségur : l'établissement respecte les obligations de partage documentaire
- Traçabilité complète : chaque publication porte l'identité de l'auteur (RPPS), le statut et l'INS-NIR
- Base pour l'évolution MHD : l'infrastructure XDS.b documentée est le socle sur lequel viendra se greffer la passerelle MHD dans une trajectoire Ségur vague 2

---

## 3. Mon rôle

| Activité | Détail |
|----------|--------|
| **Cadrage** | Identification des systèmes sources, définition des 5 flux (F1→F5), périmètre des 2 cas détaillés |
| **Choix d'architecture** | Positionnement des acteurs XDS.b, rôle de la DRIMbox Source/Consommatrice dans le cadre DRIM-M |
| **Standardisation** | Mapping des métadonnées XDSDocumentEntry sur les JDV ANS (JDV_J02, JDV_J07, JDV_J57, JDV_J58, JDV_J60) |
| **Documentation** | DAT v2.0 (8 sections), diagrammes de séquence Draw.io, 2 XDSDocumentEntry JSON détaillés + SubmissionSet |
| **Analyse critique** | Évaluation des limites et avantages de XDS.b, articulation avec FHIR/MHD, justification MOS du choix DocumentEntry |

---

## 4. Architecture et standards

### Les 4 acteurs IHE XDS.b à Sainte-Marie

| Acteur XDS.b | Système | Rôle |
|-------------|---------|------|
| Document Source | DPI Orbis | Publie CR consultation et lettre de sortie |
| Document Source | PACS/RIS Sectra + DRIMbox Source | Publie CR imagerie et KOS via DRIM-M |
| Document Source | LIS Sysmex | Publie résultats biologie |
| Document Repository | DMP (Cnam) + DRIMbox | Stocke le contenu des documents |
| Document Registry | DMP (Cnam) | Indexe les métadonnées |
| Document Consumer | DPI Orbis / médecin libéral | Recherche et récupère les documents |

### Parcours Jean DUPONT — vue des flux

```
J0 — Admission cardiologie
  F1 · ITI-41 · Orbis ──────────────► DMP · CR consultation (LOINC 11488-4) ← CAS DÉTAILLÉ
  F2 · ITI-41 · Sectra/DRIMbox ──────► DMP · CR échographie (LOINC 18748-4) ← CAS DÉTAILLÉ
  F3 · ITI-41 · Sysmex ──────────────► DMP · Résultats biologie (LOINC 11502-2) ← pattern F1

J+2 — Sortie
  F4 · ITI-41 · Orbis ──────────────► DMP · Lettre de sortie (LOINC 34105-7) ← pattern F1

Post-sortie — Consultation médecin libéral
  F5a · ITI-18 · Consumer ──────────► DMP Registry · FindDocuments
  F5b · ITI-43 · Consumer ──────────► DMP Repository · RetrieveDocumentSet
```

### Spécificité DRIM-M — flux imagerie (F2)

Dans le cadre DRIM-M (Dispositif de Référencement des Imageries Médicales), la DRIMbox joue un rôle d'intermédiation — pas de simple connecteur DMP. L'ANS distingue deux composants :

- **DRIMbox Source** : publie les KOS (Key Object Selection — références aux images DICOM) et le CR textuel vers le DMP Registry. Elle ne stocke pas les images — elles restent dans le PACS Sectra.
- **DRIMbox Consommatrice** : portail d'accès sécurisé au PACS depuis l'extérieur. Le médecin libéral récupère le KOS depuis le DMP, puis contacte la DRIMbox Consommatrice pour streamer les images DICOM depuis le PACS via le réseau DRIM-M.

### Standards appliqués

| Standard | Usage |
|----------|-------|
| IHE XDS.b | Profil de partage documentaire — transactions ITI-41/42/18/43 |
| CI-SIS ANS | Cadre d'interopérabilité français — JDV, codes, exigences DMP |
| DRIM-M ANS | Cadre imagerie médicale — DRIMbox Source/Consommatrice, KOS |
| IHE MHD | Profil cible — équivalent FHIR/REST de XDS.b |
| SOAP / ebXML | Protocole de transport des transactions XDS.b |
| VIHF | Authentification des systèmes sources vers le DMP |

### Sécurité

- Authentification des systèmes sources via **VIHF** (certificat CPS ou logiciel)
- Chiffrement **TLS 1.2+** sur toutes les connexions SOAP/HTTPS
- Traçabilité obligatoire des accès DMP — conformité HDS et RGPD
- Gestion des habilitations DMP par profil professionnel
- Stratégie de rejeu Mirth Connect en cas d'indisponibilité DMP

---

## 5. Décisions clés

### Pourquoi XDS.b et pas MHD directement ?
XDS.b est le protocole natif du DMP français — il est opérationnel, certifié, et les connecteurs éditeurs (Orbis, Sectra, Sysmex) l'implémentent en production. Choisir MHD aujourd'hui imposerait d'ajouter une passerelle MHD/XDS entre le serveur FHIR et le DMP — une complexité supplémentaire sans bénéfice immédiat pour un établissement qui dispose déjà de connecteurs XDS.b certifiés. XDS.b est le choix pragmatique pour l'existant ; MHD est la trajectoire cible pour les nouvelles intégrations (voir DAT section 6.3).

### Pourquoi documenter uniquement le DocumentEntry et pas toutes les classes MOS ?
Le modèle MOS ANS définit 6 classes dans la partie PartageDocument (LotSoumission, Fiche, Document, Professionnel, PersonnePriseCharge, Dispositif). Le DocumentEntry (Fiche) est documenté en détail car c'est l'objet central du Registry — c'est lui que le Consumer interroge via ITI-18 et qui porte toute la sémantique métier. Le SubmissionSet (LotSoumission) est construit automatiquement par le connecteur éditeur. Les classes Professionnel/PatientPriseCharge/Dispositif sont des sous-composants intégrés dans le DocumentEntry en XDS — pas des objets séparés.

### Pourquoi l'INS-NIR et pas l'IPP comme patientId ?
L'IPP est l'identifiant local de la clinique — il ne signifie rien pour le DMP Registry national. Sans INS-NIR qualifiée comme `patientId`, la publication est rejetée ou crée un dossier orphelin. C'est la raison d'être du Projet 2 : le profil `SteMariePatientINS` garantit que l'INS-NIR est disponible sur chaque ressource Patient avant toute publication XDS.

### Pourquoi un formatCode différent pour l'imagerie (F2) ?
Le CR d'échographie transite par la DRIMbox Source — elle impose le formatCode `urn:ihe:rad:TEXT` (IHE Radiology), distinct du `urn:ihe:iti:xds-sd:pdf:2008` standard. Ce n'est pas un choix local — c'est une contrainte du cadre DRIM-M documentée dans le CI-SIS imagerie. De même, le `repositoryUniqueId` du flux F2 pointe vers la DRIMbox et non vers le DMP Repository standard.

### Limite acceptée — dépendance au DMP
Les flux F1 à F4 sont bloqués si le DMP Registry (Cnam) est indisponible. Ce risque est accepté et mitigé par une file d'attente dans l'ESB Mirth Connect — les messages sont conservés et republié à la reconnexion. Les erreurs fonctionnelles (INS absente, code JDV invalide) nécessitent une correction métier avant rejeu.

---

## 6. Résultats

### Ce qui a été livré
- **DAT v2.0** (8 sections) : contexte + hypothèses portfolio, acteurs, architecture fonctionnelle, métadonnées détaillées (justification MOS, 2 cas, SubmissionSet, ENF, gestion erreurs), analyse critique, articulation FHIR/MHD
- **Diagrammes de séquence Draw.io** : vue globale + zoom ITI-41 flux nominal + zoom ITI-41 flux DRIMbox + zoom ITI-18/43
- **2 fichiers JSON XDSDocumentEntry** détaillés (CR consultation + CR imagerie) avec SubmissionSet associé
- **Synthèse F3/F4** en tableau — pattern identique à F1, seuls typeCode et auteur changent

### Ce que le projet a amélioré
- **Continuité documentaire** : le parcours Jean DUPONT J0→sortie est entièrement couvert — 2 cas détaillés, 2 synthétisés, 1 flux de consultation
- **Conformité réglementaire** : métadonnées tracées vers les JDV ANS officiels — auditables et maintenables
- **Vision d'évolution** : la section articulation FHIR/MHD montre le chemin vers une architecture Ségur vague 2 via passerelle MHD/PFI sans tout reconstruire

### Ce que ça prouve sur mon niveau
- Maîtrise des profils IHE XDS.b et de leur implémentation française (CI-SIS, JDV, DRIM-M)
- Capacité à nuancer la réalité technique (rôle précis DRIMbox, distinction Source/Consommatrice, KOS)
- Compréhension des enjeux de gouvernance des métadonnées (JDV ANS, SMT, Gazelle)
- Posture d'architecte : savoir où XDS.b montre ses limites et comment MHD prend le relais

---

## 7. Ce que ce projet démontre

- **Maîtrise IHE** : XDS.b, DRIM-M, transactions ITI-41/42/18/43, acteurs, métadonnées — pas juste la théorie mais les choix concrets pour Sainte-Marie
- **Ancrage réglementaire français** : CI-SIS, JDV ANS, DMP, DRIMbox, VIHF, Ségur — le vocabulaire et les outils du terrain
- **Analyse critique** : identification des limites (dépendance DMP, protocole vieillissant, biologie CDA R2 N3 en cible) ET proposition d'une trajectoire d'évolution (MHD/PFI)
- **Cohérence d'architecture** : ce projet est le point de convergence des 3 projets précédents — l'INS-NIR du Projet 2, les flux HL7 du Projet 1 et le serveur FHIR du Projet 3 s'articulent tous ici

---

## 8. Structure du dépôt

```
Projet-4-ihe-xds/
├── README.md                                      ← ce fichier
├── dat/
│   └── DAT_Projet4_IHE_XDS_Sainte-Marie_v2.0.docx
├── diagrammes/
│   └── XDS_Sequences_Sainte-Marie_v2.0.drawio
└── instances/
    ├── metadata_CR_consultation.json              ← DocumentEntry + SubmissionSet (F1)
    └── metadata_CR_imagerie_DRIMbox.json          ← DocumentEntry + SubmissionSet (F2)
```

---

## Liens avec les autres projets

| Projet | Lien |
|--------|------|
| **Projet 1** — HL7 v2 | L'admission ADT^A01 (F01) est le déclencheur métier de la publication XDS ITI-41 (F1) |
| **Projet 2** — Profil FHIR | L'INS-NIR du profil `SteMariePatientINS` est le `patientId` de toutes les XDSDocumentEntry |
| **Projet 3** — Serveur FHIR | Le serveur Hapi est la future brique MHD Source — `DocumentReference` FHIR vers DMP via passerelle/PFI |
| **Projet 5** — Architecture SI | XDS.b est la couche de partage documentaire de l'architecture globale — résilience Mirth, gouvernance, sécurité |

---

## Ressources

| Ressource | URL |
|-----------|-----|
| CI-SIS ANS | https://esante.gouv.fr/offres-services/ci-sis/espace-publication |
| SMT — Terminologies ANS | https://mos.esante.gouv.fr |
| MOS ANS — PartageDocument | https://mos.esante.gouv.fr/19.html |
| ANS DRIM-M | https://esante.gouv.fr/offres-services/programmes-services/drim-m |
| Gazelle ANS | https://gazelle.esante.gouv.fr |
| IHE ITI XDS.b | https://www.ihe.net/resources/technical_frameworks/#IT |
| IHE MHD | https://www.ihe.net/resources/technical_frameworks/#IT |
| JDV_J02 healthcareFacilityCode | https://interop.esante.gouv.fr/ig/nos/1.4.0/ValueSet-JDV-J02 |

---

> **Note portfolio** : Ce projet est fictif, réalisé à des fins de portfolio. Les identifiants, patients, OID et endpoints sont simulés. L'objectif est de démontrer la compréhension des profils IHE XDS.b, du cadre DRIM-M et de leur articulation avec FHIR/MHD.

---

*Portfolio Interopérabilité SI Santé — Reconversion professionnelle consultante/architecte — 2026*
