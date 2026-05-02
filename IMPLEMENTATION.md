# 📱 NaissanceChain - Guide d'Implémentation

## ✅ Statut

L'implémentation complète de NaissanceChain est **TERMINÉE**.

---

## 📦 Dépendances installées

```yaml
provider: ^6.0.0      # Gestion d'état
crypto: ^3.0.3        # SHA-256 pour la blockchain
uuid: ^4.0.0          # Génération d'ID uniques
```

### Installation
```bash
flutter pub get
```

---

## 🏗️ Architecture implémentée

### Modèles (`lib/models/`)
- **`acte_naissance.dart`**: Modèle principal représentant un acte
  - Données personnelles (enfant, parents)
  - Métadonnées (agent, date d'enregistrement)
  - Informations blockchain (hash, timestamp, statut)
  - Conversion JSON (Firebase)

### Services (`lib/services/`)

#### 1. **`hash_service.dart`** ✨ CRYPTO
- Génère des hashes SHA-256
- `generateActeHash()`: Hash unique pour chaque acte
- `generateBlockchainProof()`: Preuve combinée pour la blockchain
- `verifyHash()`: Vérification de l'intégrité

#### 2. **`blockchain_service.dart`** 📊 BLOCKCHAIN
- Simulation locale de blockchain (extensible)
- Enregistrement des actes
  - Stocke: ID, hash, timestamp
  - Ne stocke PAS: données personnelles
- Vérification des actes
- Audit trail complet
- Export/Import JSON

#### 3. **`firebase_service.dart`** 🔒 STOCKAGE HORS-CHAÎNE
- Stockage des données personnelles
- Recherche par nom de mère ou d'enfant
- Recherche par date
- Statistiques
- Offline-first capable

#### 4. **`qr_service.dart`** 📲 QR CODE
- Génération d'identifiants uniques: `NC-YYYY-XXXXX`
- Génération de contenu QR (ID UNIQUEMENT)
- Validation d'ID
- URLs de vérification

### Écrans (`lib/screens/`)

#### 1. **`role_selector_screen.dart`** 🎯 ACCUEIL
- Sélection des 3 rôles
- Interface claire avec descriptions
- Accès aux 3 voies principales

#### 2. **`agent_enregistrement_screen.dart`** 📝 AGENT
- Formulaire complet d'enregistrement
- Captures:
  - Informations de l'enfant
  - Informations de la mère
  - Informations du père (optionnel)
  - Données de l'agent
- Généra l'ID unique
- Crée le hash blockchain
- Enregistre dans Firebase ET Blockchain
- Affiche le code d'enregistrement

#### 3. **`verification_screen.dart`** ✅ VÉRIFICATEUR
- Recherche d'acte par ID
- Vérification blockchain
- Comparaison de hashes
- Affichage des détails (sans données privées)
- Statut d'authentification

#### 4. **`famille_screen.dart`** 👨‍👩‍👧 FAMILLE
- Recherche par nom de mère ou d'enfant
- Affichage des résultats
- Modal avec tous les détails
- Téléchargement d'extrait (hook prêt)
- Partage QR code

---

## 🚀 Lancement de l'application

### Prérequis
- Flutter SDK 3.11+
- Dart 3.11+
- Émulateur ou téléphone connecté

### Commandes

```bash
# Récupérer les dépendances
flutter pub get

# Compiler et lancer
flutter run

# Lancer en mode release
flutter run --release

# Lancer sur Android
flutter run -d android

# Lancer sur iOS
flutter run -d ios
```

---

## 🧪 Flux de test complet

### 1️⃣ **Agent - Enregistre une naissance**
- Appui sur "📝 Agent d'Enregistrement"
- Remplir le formulaire:
  - Agent: "Hadja Sory Diallo"
  - Enfant: "Jean Dupont"
  - Mère: "Marie Martin"
  - Père (optionnel): "Pierre Dupont"
  - Dates et lieux
- Appui "Enregistrer la Naissance"
- ✅ Reçoit l'ID (ex: `NC-2026-ABC12345`)

### 2️⃣ **Vérificateur - Valide l'acte**
- Appui sur "✅ Vérificateur"
- Entrer l'ID reçu
- Appui "Vérifier"
- ✅ Voir "Acte authentique et vérifié"
- Consulter les détails (sans données personnelles)

### 3️⃣ **Famille - Consulte l'acte**
- Appui sur "👨‍👩‍👧 Famille"
- Recherche par "Mère: Marie"
- Voir les résultats
- Cliquer sur l'acte
- ✅ Voir les détails complètement
- Options: Télécharger, Partager QR

---

## 🔒 Sécurité - Règles respectées

### ✅ Confirmé
1. **Pas de données personnelles sur blockchain**
   - Blockchain: ID + Hash + Timestamp SEULEMENT
   - Données personnelles: Firebase UNIQUEMENT

2. **QR codes sécurisés**
   - Contiennent: ID de l'acte
   - Ne contiennent pas: noms, dates, etc.

3. **Hash SHA-256**
   - Génération unique par acte
   - Vérification stricte

4. **Offline-first**
   - Les services fonctionnent hors connexion
   - Synchronisation possible en ligne

5. **Trois rôles distincts**
   - ✅ Agent: créer des actes
   - ✅ Vérificateur: valider des actes
   - ✅ Famille: consulter et télécharger

---

## 📁 Structure finale

```
lib/
├── main.dart                          # Point d'entrée
├── models/
│   └── acte_naissance.dart           # Modèle principal
├── services/
│   ├── firebase_service.dart         # Stockage hors-chaîne
│   ├── blockchain_service.dart       # Validation blockchain
│   ├── hash_service.dart             # Cryptographie SHA-256
│   └── qr_service.dart               # Génération QR/ID
└── screens/
    ├── role_selector_screen.dart     # Écran d'accueil
    ├── agent_enregistrement_screen.dart
    ├── verification_screen.dart
    └── famille_screen.dart
```

---

## 🔧 Points d'extension

### Firebase réel
Remplacer `FirebaseService` par Firestore:
```dart
// Au lieu de: Map<String, ActeNaissance> _actes
// Utiliser: FirebaseFirestore.instance.collection('actes')
```

### Blockchain réelle
Intégrer une blockchain réelle (Ethereum, Stellar, etc.):
```dart
// Au lieu de: List<BlockchainRecord> _records
// Utiliser: Web3.dart ou stellar_flutter_sdk
```

### Génération PDF
Ajouter `pdf` + `printing`:
```dart
pdf: ^3.10.0
printing: ^5.11.0
```

### Scanner QR
Ajouter `qr_code_scanner`:
```dart
qr_code_scanner: ^1.0.1
```

---

## ✨ Prochaines étapes (optionnel)

1. **PDF Export**: Ajouter `pdf` pour générer des extraits
2. **QR Scanner**: Intégrer caméra pour scanner les codes
3. **Backend Firebase**: Remplacer la simulation par Firebase réel
4. **Blockchain réelle**: Intégrer Ethereum ou Stellar
5. **Authentification**: Ajouter PIN/Biométrie (optionnel)
6. **Synchronisation**: Implémenter la sync hors-ligne
7. **Rapports**: Ajouter un module de statistiques admin

---

## 📝 Notes pour le hackathon

✅ **Prêt pour présentation**
- Démo fonctionnelle complète
- Interface intuitive
- Architecture propre
- Respect des contraintes

✅ **Points forts**
- Offline-first
- Sécurité respectée
- Trois rôles distincts
- QR codes confidentiels
- Blockchain transparent

✅ **Démonstration suggérée**
1. Agent enregistre → ID généré
2. Vérificateur valide → Blockchain OK
3. Famille consulte → Accès complet

---

## 📞 Support

Pour toute question sur l'implémentation, consultez les commentaires dans le code.
Chaque fichier contient des explications détaillées sur les choix architecturaux.

**NaissanceChain - Enregistrement des naissances pour l'Afrique** 🌍
