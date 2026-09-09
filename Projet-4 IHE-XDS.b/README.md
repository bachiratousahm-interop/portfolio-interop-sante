# Projet 4 - Partage documentaire IHE XDS.b / MHD

## Objectif

Ce projet étudie une architecture de **partage documentaire de santé** pour la Clinique Sainte-Marie, établissement fictif utilisé comme fil conducteur du portfolio.

Le scénario principal repose sur **IHE XDS.b** pour la publication et la recherche de documents médicaux, avec une trajectoire cible vers **FHIR R4 / IHE MHD / CI-SIS PDSm**.

> Cas pédagogique - aucune connexion réelle au DMP ni infrastructure XDS de production n'est déployée.

---

## Périmètre étudié

Le projet couvre notamment :

- la publication d'un compte rendu médical vers le DMP ;
- les métadonnées `DocumentEntry` et `SubmissionSet` ;
- les transactions XDS.b `ITI-41`, `ITI-18` et `ITI-43` ;
- la gestion des erreurs, du retry et du rejeu ;
- un scénario d'imagerie avec DRIMbox et DICOM KOS ;
- une trajectoire documentaire FHIR R4 avec IHE MHD / PDSm.

---

## Architecture documentaire

```text
DPI / RIS / LIS
      |
      v
PFI documentaire
      |
      v
XDS.b
      |
      +-- Registry
      +-- Repository
      |
      v
DMP / consommateurs
```

La PFI assure les contrôles, la préparation des métadonnées, le routage et la journalisation des échanges.

---

## Trajectoire MHD / FHIR R4

La partie MHD est étudiée comme **cible d'évolution** et non comme implémentation du POC.

Correspondances principales :

```text
DocumentEntry  -> DocumentReference
SubmissionSet  -> List
Folder         -> List
Document       -> Binary
```

---

## Livrables

Le dossier contient :

- `DAT-XDS-pdsm-Sainte-Marie.pdf`
- le dossier `Diagrams/` avec les trois schémas principaux du projet.

Les diagrammes présentent :

1. l'architecture cible XDS.b ;
2. la publication d'un compte rendu vers le DMP ;
3. le scénario DRIMbox / DICOM KOS.

---

## Limites

Ce projet est une **étude d'architecture et de spécification**.

Ne sont pas déployés :

- une connexion réelle au DMP ;
- une infrastructure XDS.b de production ;
- une DRIMbox certifiée ;
- une implémentation réelle de MHD / PDSm.

Toutes les données et identifiants utilisés sont fictifs.

---

**Standards et technologies :** IHE XDS.b · CI-SIS · DMP · IHE MHD · PDSm · FHIR R4 · DICOM KOS · DRIM-M