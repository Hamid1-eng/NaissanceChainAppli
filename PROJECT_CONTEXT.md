# NaissanceChain – Contexte du projet

## Hackathon
MIABE Hackathon 2026  
Thème : La blockchain comme levier du développement durable en Afrique  
Pays : Guinée (GN)  
Catégorie : Identité numérique & Registres civils  

---

## Problématique
En Guinée, seulement 58 % des naissances sont enregistrées officiellement.
Dans les zones rurales et forestières, ce taux est inférieur à 40 %.
Résultat : environ 1,8 million d’enfants n’ont pas d’acte de naissance légal.

Sans acte de naissance :
- Les enfants ne peuvent pas accéder à l’école
- Les enfants ne peuvent pas accéder aux soins de santé
- Les enfants n’ont pas d’identité juridique
- L’État ne peut pas planifier efficacement les politiques publiques

L’obtention d’un acte de naissance tardif peut prendre entre 3 et 8 mois
et nécessite souvent des déplacements difficiles pour les familles.

---

## Solution proposée : NaissanceChain
NaissanceChain est un système mobile d’enregistrement des naissances
basé sur la technologie blockchain.

La solution permet d’enregistrer une naissance depuis n’importe quel point du territoire guinéen :
- maternités rurales
- cases de santé
- villages reculés

Chaque naissance enregistrée génère :
- un identifiant unique
- un extrait de naissance numérique
- un QR code permettant une vérification instantanée

Les écoles, hôpitaux et administrations peuvent vérifier l’authenticité
d’un acte de naissance en scannant le QR code.

---

## Utilisateurs cibles
- Agents de santé et sages‑femmes
- Agents d’état civil mobiles
- Familles
- Écoles et hôpitaux
- Ministère de la Justice et de l’Administration du Territoire (Guinée)

---

## Fonctionnalités principales
- Enregistrement des naissances via application mobile
- Fonctionnement hors connexion (offline‑first)
- Génération d’un identifiant unique pour chaque naissance
- Génération d’un extrait de naissance numérique
- QR code pour la vérification
- Vérification par les administrations scolaires et sanitaires
- Accès famille pour consulter et télécharger l’extrait

---

## Principe d’utilisation de la blockchain
- La blockchain est utilisée comme **registre infalsifiable de preuves**
- Aucune donnée personnelle n’est stockée sur la blockchain
- Seules les informations suivantes sont enregistrées :
  - Identifiant de l’acte
  - Hash cryptographique (SHA‑256)
  - Horodatage (timestamp)
- La blockchain empêche la falsification et les modifications rétroactives
- Elle garantit la pérennité et la traçabilité des actes de naissance

---

## Stockage hors‑chaîne (Firebase)
- Les données personnelles sont stockées hors blockchain
- Firebase est utilisé pour :
  - les informations de naissance
  - les données familles
  - l’extrait numérique (PDF ou format digital)
- Firebase assure la disponibilité et la synchronisation des données
- Firebase **n’est pas** une blockchain

---

## Vérification par QR code
- Chaque extrait contient un QR code
- Le QR code contient l’identifiant de l’acte
- Les écoles et hôpitaux peuvent scanner le QR code
- La vérification compare :
  - les données hors‑chaîne (Firebase)
  - la preuve enregistrée sur la blockchain

---

## Approche hors connexion (Offline‑First)
- Les naissances peuvent être enregistrées sans connexion Internet
- La preuve est générée localement sur l’appareil
- L’ancrage sur la blockchain se fait dès que la connexion est disponible
- Cette approche est adaptée aux zones rurales et reculées de la Guinée

---

## Technologies utilisées
- Flutter : application mobile
- Firebase : stockage opérationnel hors‑chaîne
- Blockchain : preuve d’existence et immutabilité
- QR Code : mécanisme universel de vérification

---

## Objectif du projet
Présenter un prototype fonctionnel dans le cadre du MIABE Hackathon 2026,
montrant comment la blockchain peut résoudre les défis de l’état civil,
améliorer l’accès à l’éducation, à la santé et à l’identité juridique en Guinée.

---

## Objectifs de Développement Durable (ODD)
- ODD 3 : Bonne santé et bien‑être
- ODD 4 : Éducation de qualité
- ODD 10 : Inégalités réduites
- ODD 16 : Paix, justice et institutions efficaces