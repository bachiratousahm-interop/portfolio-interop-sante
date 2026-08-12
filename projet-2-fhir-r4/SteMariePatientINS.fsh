Alias: $fr-core-patient-ins = https://hl7.fr/ig/fhir/core/StructureDefinition/fr-core-patient-ins

Profile: SteMariePatientINS
Parent: $fr-core-patient-ins
Id: SteMariePatientINS
Title: "Profil Patient INS — Clinique Sainte-Marie"
Description: """
Profil Patient pour la Clinique Sainte-Marie, dérivé de FRCorePatientINSProfile v2.1.0.

Le profil conserve les contraintes nationales relatives à l'identité INS
et ajoute les contraintes locales suivantes :
- au moins deux identifiants pour les usages d'échange ;
- un IPP Sainte-Marie obligatoire ;
- une organisation gestionnaire obligatoire.
"""

* ^url = "https://fhir-sainte-marie.up.railway.app/fhir/StructureDefinition/SteMariePatientINS"
* ^version = "1.0.1"
* ^status = #active

// -------------------------------------------------------------------
// Identifiants
// -------------------------------------------------------------------

// Renforcement local : au moins deux identifiants pour le patient
* identifier 2..*

// La slice PI existe déjà dans FR Core et représente l'IPP.
// Sainte-Marie la rend obligatoire et unique.
* identifier[PI] 1..1

// Namespace de l'IPP attribué par la Clinique Sainte-Marie
* identifier[PI].system = "https://fhir-sainte-marie.up.railway.app/fhir/Patient"

// -------------------------------------------------------------------
// Organisation gestionnaire
// -------------------------------------------------------------------

// Tout Patient conforme au profil Sainte-Marie
// doit avoir une organisation gestionnaire
* managingOrganization 1..1