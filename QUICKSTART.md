# 🚀 QUICKSTART - NaissanceChain

## ⚡ En 5 minutes

### 1. Installez les dépendances
```bash
flutter pub get
```

### 2. Lancez l'app
```bash
flutter run
```

### 3. Testez les 3 rôles

---

## 🧪 Scénario de test complet (10 min)

### 📝 **Agent - Créer un acte**

```
Écran 1: Accueil
├─ Appui: "📝 Agent d'Enregistrement"

Écran 2: Formulaire
├─ Agent: "Hadja Sory Diallo"
├─ Enfant: "Jean Dupont"
├─ Date naissance: 2026-04-15 (appui calendrier)
├─ Lieu: "Conakry"
├─ Mère: "Marie" + "Martin"
├─ Père: "Pierre" + "Dupont" (optionnel)
├─ Appui: "Enregistrer la Naissance"

Écran 3: Succès ✅
├─ Voir: "ID unique: NC-2026-ABC12345"
├─ Blockchain: Validée ✓
├─ QR Code: Généré ✓
```

**Résultat**: ID généré = `NC-2026-ABC12345`

---

### ✅ **Vérificateur - Valider l'acte**

```
Écran 1: Accueil
├─ Appui: "✅ Vérificateur (École/Hôpital)"

Écran 2: Recherche
├─ Entrer: "NC-2026-ABC12345"
├─ Appui: "Vérifier"

Écran 3: Résultat ✅
├─ Message: "✅ Acte authentique et vérifié"
├─ Détails affichés (SANS données perso)
│  ├─ ID: NC-2026-ABC12345
│  ├─ Hash: a1b2c3d4... (court)
│  ├─ Statut: Vérifié ✓
│  └─ Timestamp: 2026-04-30
```

**Sécurité**: Les noms ne sont PAS affichés ✓

---

### 👨‍👩‍👧 **Famille - Consulter l'acte**

```
Écran 1: Accueil
├─ Appui: "👨‍👩‍👧‍👦 Famille"

Écran 2: Recherche
├─ Sélectionner: "Par mère"
├─ Entrer: "Martin" (nom de mère)
├─ Résultat: "Jean Dupont - Mère: Marie Martin"

Écran 3: Détails (Modal)
├─ Voir TOUS les détails:
│  ├─ Enfant: Jean Dupont
│  ├─ Date: 2026-04-15
│  ├─ Lieu: Conakry
│  ├─ Mère: Marie Martin
│  ├─ Père: Pierre Dupont
│  └─ Authentification: ✅ Vérifié
├─ Boutons:
│  ├─ "Télécharger l'extrait" (hook prêt)
│  └─ "Partager le QR Code"
```

**Accès**: Complet car c'est la famille ✓

---

## 📁 Structure créée

```
✅ lib/models/
   └─ acte_naissance.dart         (Modèle)

✅ lib/services/
   ├─ firebase_service.dart       (Stockage)
   ├─ blockchain_service.dart     (Blockchain)
   ├─ hash_service.dart           (Cryptographie)
   └─ qr_service.dart             (QR/ID)

✅ lib/screens/
   ├─ role_selector_screen.dart   (Accueil)
   ├─ agent_enregistrement_screen.dart
   ├─ verification_screen.dart
   └─ famille_screen.dart

✅ lib/main.dart                   (Point d'entrée)

✅ Documentation
   ├─ PROJECT_CONTEXT.md          (Contexte)
   ├─ ARCHITECTURE.md             (Archi)
   ├─ IMPLEMENTATION.md           (Impl)
   └─ QUICKSTART.md               (Ce fichier)
```

---

## 🎮 Commandes utiles

```bash
# Récupérer dépendances
flutter pub get

# Lancer l'app
flutter run

# Lancer en release
flutter run --release

# Lancer sur Android
flutter run -d android

# Lancer sur iOS
flutter run -d ios

# Hot reload (après sauvegarde)
# Appui "r" dans le terminal

# Analyse du code
flutter analyze

# Vérifier format
dart format lib/

# Nettoyer
flutter clean
flutter pub get
```

---

## 📱 Captures d'écran attendues

### Écran 1: Accueil
```
┌─────────────────────────────────────┐
│ NaissanceChain                      │
│ Enregistrement des naissances       │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ 📝 Agent d'Enregistrement    │   │
│ │ Enregistrer une naissance    │   │
│ └──────────────────────────────┘   │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ ✅ Vérificateur              │   │
│ │ Vérifier l'authenticité      │   │
│ └──────────────────────────────┘   │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ 👨‍👩‍👧 Famille                 │   │
│ │ Consulter l'extrait          │   │
│ └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Écran 2: Formulaire Agent
```
┌─────────────────────────────────────┐
│ Enregistrement de Naissance         │
│                                     │
│ ┌─────────────────────────────┐   │
│ │ Nom de l'agent              │   │
│ │ ────────────────────────    │   │
│ └─────────────────────────────┘   │
│                                     │
│ 👶 Informations de l'enfant        │
│ ┌─────────────────────────────┐   │
│ │ Nom de l'enfant             │   │
│ │ ────────────────────────    │   │
│ └─────────────────────────────┘   │
│ [plus de champs...]                │
│                                     │
│ ┌─────────────────────────────┐   │
│ │ Enregistrer la Naissance    │   │
│ └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Écran 3: Succès
```
┌─────────────────────────────────────┐
│ ✅ Enregistrement réussi            │
│                                     │
│ L'acte a été enregistré             │
│                                     │
│ Identifiant unique:                 │
│ ┌─────────────────────────────┐   │
│ │ NC-2026-ABC12345            │   │
│ └─────────────────────────────┘   │
│                                     │
│ QR Code généré: ✓                  │
│ Blockchain validée: ✓              │
│                                     │
│ ┌─────────────────────────────┐   │
│ │ OK                          │   │
│ └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 🐛 Troubleshooting

### Erreur: "Could not resolve provider"
```
Solution: Assurez-vous que MultiProvider enveloppe MaterialApp
Location: lib/main.dart
```

### Erreur: "MissingPluginException"
```
Solution: 
flutter clean
flutter pub get
flutter run
```

### App lente
```
Solution:
flutter run --release
```

### Pas de dépendances
```
Solution:
flutter pub get
```

---

## ✅ Checklist pré-présentation

- [ ] `flutter pub get` exécuté
- [ ] `flutter run` lance sans erreur
- [ ] Écran d'accueil s'affiche
- [ ] Agent peut enregistrer une naissance
- [ ] Vérificateur peut valider
- [ ] Famille peut consulter
- [ ] Identifiants uniques générés
- [ ] Blockchain OK
- [ ] QR codes créés

---

## 📊 Données de test prêtes

### Données Agent
```
Agent: Hadja Sory Diallo
```

### Données Enfant
```
Prénom: Jean
Nom: Dupont
Date: 2026-04-15
Lieu: Conakry
```

### Données Mère
```
Prénom: Marie
Nom: Martin
```

### Données Père
```
Prénom: Pierre
Nom: Dupont
```

---

## 🎯 Objectif hackathon

L'application est **100% fonctionnelle** pour:

✅ **Démo complète**
- Enregistrement ➜ Vérification ➜ Consultation

✅ **Présentation**
- Architecture claire
- Sécurité respectée
- Code propre

✅ **Pitch**
- Offline-first ✓
- Blockchain transparente ✓
- Trois rôles distincts ✓
- Pas de données perso en blockchain ✓

---

## 🚀 Prêt!

**Lancez: `flutter run`**

**Testez les 3 rôles**

**Présentez fièrement!**

---

*NaissanceChain - Enregistrement des naissances pour l'Afrique* 🌍
