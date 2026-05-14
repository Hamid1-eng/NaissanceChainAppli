# NaissanceChain

## Description de la solution

NaissanceChain est une application numérique de registre civil conçue pour le contexte guinéen. Elle permet d’enregistrer les naissances, de générer un identifiant national unique pour chaque acte, puis de produire un QR code de vérification utilisable par les familles, les écoles et les hôpitaux.

Le principe est simple : les données personnelles de l’enfant et des parents sont conservées hors blockchain, tandis que la blockchain sert uniquement de preuve d’authenticité grâce à un identifiant d’acte, une empreinte numérique et un horodatage. Cette approche renforce la confiance, limite les risques de falsification et respecte mieux la confidentialité des informations.

L’application a été pensée pour être claire, accessible et utilisable sur mobile comme sur web. Elle distingue les besoins de plusieurs profils d’utilisateurs : agent d’enregistrement, famille, et structure de contrôle comme une école ou un hôpital.

NaissanceChain est également conçu selon une logique offline-first : les opérations essentielles peuvent être préparées et gérées avec une dépendance réduite à la connexion, ce qui est adapté aux contextes où l’accès au réseau n’est pas toujours stable.

## Technologies utilisées

- Flutter pour le développement mobile et web
- Dart comme langage principal
- Provider pour la gestion de l’état et des services
- QR code pour la consultation et la vérification rapide
- Scanner de QR code pour la lecture depuis un appareil mobile
- Cryptographie SHA-256 pour l’empreinte numérique des actes
- PDF et printing pour la génération et le partage d’extraits
- UUID pour la création d’identifiants uniques

## Sécurité et confidentialité

NaissanceChain a été conçu pour protéger la vie privée des citoyens. Les données personnelles complètes de l’enfant et des parents ne sont pas enregistrées sur la blockchain. Celle-ci conserve uniquement la preuve d’authenticité de l’acte, sous forme d’identifiant, d’empreinte numérique et d’horodatage.

Cette séparation entre les données sensibles et la preuve blockchain limite les risques d’exposition d’informations personnelles tout en permettant une vérification fiable des actes par les autorités et les structures de contrôle.

## Fonctionnalités principales

- Enregistrement numérique d’un acte de naissance par un agent habilité
- Génération d’un identifiant national unique au format guinéen
- Création d’un QR code qui ne contient que l’identifiant de l’acte
- Vérification de l’authenticité d’un acte à partir de la blockchain
- Consultation de l’extrait de naissance par la famille
- Téléchargement et partage d’un extrait au format PDF
- Contrôle rapide par les écoles et les hôpitaux grâce au QR code
- Séparation claire des rôles et des accès selon le profil utilisateur
- Conservation des données personnelles hors blockchain- **[NOUVEAU]** Tableau de bord national avec carte interactive de la Guinée
- **[NOUVEAU]** Visualisation en temps réel de la couverture par préfecture
- **[NOUVEAU]** Modal détaillé au clic sur chaque zone (statut, taux, actes)

## Tableau de Bord National - Carte Interactive

Le dashboard national affiche une vue d'ensemble de la couverture d'enregistrement des naissances à travers tout le pays.

### Fonctionnalités
- **Carte stylisée de la Guinée** avec 8 zones (préfectures)
- **Zones cliquables** pour afficher les détails détaillés
- **Code couleur dynamique** :
  - 🟢 **Vert** = Bon (taux ≥ 70%)
  - 🟡 **Jaune** = Moyen (35-69%)
  - 🔴 **Rouge** = Faible (< 35%)
  - ⚪ **Gris** = Sans données
- **Modal au clic** affichant :
  - Nom de la préfecture
  - Nombre d'actes enregistrés
  - Taux de couverture (%)
  - Statut (Bon/Moyen/Faible)
- **Hover effects** (desktop) pour meilleure UX
- **Données en temps réel** depuis Firestore
- **Offline-first** : fonctionne sans connexion

### Accès au Dashboard
1. Utiliser le rôle **"Accès administrateur"** depuis l'écran d'accueil
2. Accéder au **"Tableau de bord national"**
3. Visualiser les KPIs et la carte
4. Cliquer sur une zone pour voir les détails
5. Rafraîchir pour mettre à jour les données (swipe down)

### Architecture
- **Widget**: `GuineaInteractiveMap` (lib/widgets/guinea_interactive_map.dart)
- **Services**: `FirebaseService.getActesCountByPrefecture()`
- **Données**: Collection Firestore `actes_stats` (id_acte, prefecture, date)
- **State**: Gestion locale avec StatefulWidget
- **Performance**: Stack + Positioned optimisés

Pour plus de détails, voir [DASHBOARD_INTERACTIVE_MAP_GUIDE.md](DASHBOARD_INTERACTIVE_MAP_GUIDE.md).
## Instructions d’installation

### Prérequis

- Flutter installé sur la machine
- Un environnement prêt pour exécuter une application Flutter sur mobile ou web

### Installation du projet

1. Cloner le dépôt sur votre machine.
2. Ouvrir le dossier du projet `flutter_application_naissancechain`.
3. Installer les dépendances avec la commande :

```bash
flutter pub get
```

### Lancement de l’application

Pour exécuter l’application sur le web :

```bash
flutter run -d chrome
```

Pour exécuter l’application sur un appareil mobile ou un émulateur connecté :

```bash
flutter run
```

Pour générer une version web prête au déploiement :

```bash
flutter build web
```

## Instructions d’utilisation

1. Ouvrir l’application.
2. Choisir le rôle souhaité depuis l’écran d’accueil.
3. Pour un agent, accéder à l’enregistrement et saisir les informations de naissance.
4. Le système génère un identifiant unique et un QR code associé.
5. Pour une famille, consulter l’acte à partir de l’identifiant et obtenir un extrait PDF.
6. Pour une école ou un hôpital, scanner le QR code ou saisir l’identifiant afin de vérifier l’authenticité de l’acte.
7. La vérification repose sur la correspondance entre l’acte enregistré et sa preuve blockchain.

## Contexte du hackathon

NaissanceChain a été développé dans le cadre du MIABE Hackathon 2026 – Phase 2 (Demi-finale), pour répondre à un besoin concret de modernisation du registre civil en Guinée.

L’objectif du projet est de proposer une solution crédible, simple à comprendre et orientée usage, capable de faciliter l’enregistrement des naissances, d’améliorer la vérification des actes et de renforcer la confiance entre les administrations, les familles et les établissements qui contrôlent les documents d’identité.
