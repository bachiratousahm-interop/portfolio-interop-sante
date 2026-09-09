# Mirth Connect Channels HL7 v2 vers FHIR

Export des channels Mirth Connect démontrant l'intégration HL7 v2 → FHIR pour la Clinique Sainte-Marie, déployés sur un VPS OVH (Docker) avec un serveur HAPI FHIR (Railway) comme cible.

## Architecture

```
Système source (simulé via netcat)
   → TCP/MLLP → Mirth Connect (Source + Filter + Transformer)
      → HTTP POST/PUT → HAPI FHIR (Railway)
```

## Channels

### `ADT_HL7v2_to_FHIR_SainteMarie` (port 6661)
Flux d'admission simple, message HL7 v2 ADT^A01 → ressource FHIR `Patient` unique, envoyée en `POST` direct.

### `bundle_HL7v2_to_FHIR_SainteMarie` (port 6666)
Flux d'admission enrichi : même message ADT, mais lit aussi le segment PV1 (visite) pour construire un **Bundle Transaction** contenant :
- `Patient` (créé ou mis à jour via `PUT` conditionnel sur l'identifiant, pour éviter les doublons)
- `Encounter` (statut déduit dynamiquement du type d'événement HL7, avec une ressource `Location` **contenue** pour le lieu d'hospitalisation)

### `ORU_HL7v2_to_FHIR_SainteMarie` (port 6662)
Flux de résultats de laboratoire : message HL7 v2 ORU^R01 → ressource FHIR `Observation`, avec :
- **Filter côté Source** : ne traite que les résultats au statut "Final" (`OBX-11 = F`)
- **Filter côté Destination** : n'envoie que les résultats anormaux (`OBX-8 ≠ N`)
- Référence au patient par **recherche conditionnelle** (`Patient?identifier=...`), enveloppée dans un Bundle Transaction (obligatoire pour ce mécanisme)

## Limitations connues

- Conformité au profil FR Core / INS non vérifiée formellement (identifiants construits avec un système maison, pas la structure d'identifiant qualifié INS).
- Aucune validation des formats sources avant transformation (un champ HL7 malformé produit une donnée FHIR incohérente plutôt qu'un rejet contrôlé).
- Le serveur FHIR de démonstration utilise une base H2 embarquée sans volume persistant (les données peuvent être perdues lors d'un redémarrage du service).

## Pour réimporter un channel

Dans Mirth Connect Administrator : **Channels → Import Channel**, sélectionner le fichier `.xml` correspondant.

## Documentation complémentaire

Le détail de l'architecture, du mapping HL7 v2 → FHIR et des expérimentations Mirth Connect est présenté dans le **Projet 5 - Architecture d'intégration SI Santé**.
