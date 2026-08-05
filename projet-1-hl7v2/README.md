
# Projet 1 : Cartographie des flux HL7 v2

## Objectif

Modélisation complète des flux d'interopérabilité HL7 v2 de la Clinique 
Sainte-Marie, établissement fictif de 180 lits à Montpellier.



## Établissement

| Paramètre | Valeur |
|-----------|--------|
| Nom | Clinique Sainte-Marie (fictif) |
| Localisation | Montpellier (34000) |
| Capacité | 180 lits |
| Spécialité | Cardiologie |
| Patient de référence | Jean DUPONT - IPP 00012345 |



## Systèmes documentés

| Système | Logiciel | Rôle |
|---------|----------|------|
| DPI | Easily | Dossier Patient Informatisé |
| ESB | Mirth Connect | Bus d'intégration |
| LIS | Sysmex | Laboratoire |
| PACS | Sectra | Imagerie |
| RIS | Sectra | Radiologie |
| PUI | Pharma | Pharmacie |
| SIC | Cardiobase | Cardiologie |



## Flux documentés (17 flux HL7 v2)

| Type | Description |
|------|-------------|
| ADT | Admission, Transfert, Sortie |
| ORM | Ordres (examens, médicaments) |
| ORU | Résultats d'examens |
| MDM | Documents médicaux |
| RDE | Prescription médicamenteuse |
| RDS | Dispensation médicamenteuse |
| SIU | Planification des rendez-vous |



## Messages HL7 de référence

| Fichier | Message | Description |
|---------|---------|-------------|
| `messages/ADT_A01_Jean_Dupont.hl7` | ADT^A01 | Admission de Jean Dupont |
| `messages/ORM_O01_Jean_Dupont.hl7` | ORM^O01 | Prescription d'examen |
| `messages/ORU_R01_Jean_Dupont.hl7` | ORU^R01 | Résultat d'examen |



## Fichiers

| Fichier | Description |
|---------|-------------|
| `DAT_Sainte_Marie_Interoperabilite.docx` | Dossier d'Architecture Technique complet |
| `DAT_Sainte_Marie_Interoperabilite.pdf` | Version PDF du DAT |
| `messages/` | Messages HL7 v2 annotés |



## Standard utilisé

**HL7 v2.5**  standard de messagerie hospitalière pour les échanges 
entre systèmes de santé.


## Outils utilisés

- **Draw.io** — schémas de flux et architecture