# 🔗 Ressources et Références

## 📚 Documentation officielle

### Flutter
- [Flutter.dev](https://flutter.dev)
- [Flutter Docs](https://docs.flutter.dev)
- [Dart Language](https://dart.dev)

### Libraries utilisées

#### 1. **Provider** (State Management)
```yaml
provider: ^6.0.0
```
- [Documentation](https://pub.dev/packages/provider)
- Usage: `ChangeNotifierProvider`, `MultiProvider`
- Alternative: GetX, BLoC, Riverpod

#### 2. **Crypto** (SHA-256)
```yaml
crypto: ^3.0.3
```
- [Documentation](https://pub.dev/packages/crypto)
- Usage: `sha256.convert(utf8.encode(data))`
- Algorithme: SHA-256 sécurisé

#### 3. **UUID** (Génération d'ID)
```yaml
uuid: ^4.0.0
```
- [Documentation](https://pub.dev/packages/uuid)
- Usage: `Uuid().v4()` pour génération aléatoire
- Format: UUID4 RFC 4122 compliant

---

## 🎯 Concepts clés implémentés

### 1. Provider pour gestion d'état
```dart
// Configuration dans main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FirebaseService()),
    ChangeNotifierProvider(create: (_) => BlockchainService()),
  ],
)

// Utilisation dans les screens
context.read<FirebaseService>()
Consumer<FirebaseService>()
```

### 2. SHA-256 pour hachage
```dart
// Génération
sha256.convert(utf8.encode(data)).toString()

// Propriétés
- Déterministe (même entrée = même sortie)
- Irréversible (impossible d'inverser)
- Unique (minuscule changement = hash complètement différent)
```

### 3. UUID pour identifiants
```dart
// Génération
Uuid().v4() // UUID aléatoire

// Format personnalisé
'NC-${year}-${uuid.substring(0, 8)}'
```

### 4. Modèle ChangeNotifier
```dart
class FirebaseService extends ChangeNotifier {
  // Modifie les données
  void updateData() {
    _data = newValue;
    notifyListeners(); // Notifie UI
  }
}
```

---

## 🏗️ Patterns de conception

### 1. Service Locator Pattern
```dart
// Enregistrement
MultiProvider(providers: [...])

// Accès
context.read<FirebaseService>()
```

### 2. Observer Pattern
```dart
// FirebaseService observe _actes
// UI observe FirebaseService via Consumer
```

### 3. Separation of Concerns
```
UI (Écrans) → Services (Logique) → Models (Données)
```

### 4. Offline-First Pattern
```
Local Storage → Sync when online
```

---

## 🔐 Bonnes pratiques de sécurité

### 1. Validation des entrées
```dart
if (value!.isEmpty) return 'Requis';
if (!isValidFormat(value)) return 'Format invalide';
```

### 2. Pas de données sensibles en logs
```dart
// ❌ Ne pas faire
debugPrint('Password: $password');

// ✅ Faire
debugPrint('Login attempted');
```

### 3. Chiffrement des données sensibles
```dart
// Actuellement: simulation
// Production: utiliser EncryptedSharedPreferences
```

### 4. Validation blockchain
```dart
// Vérifier le hash avant d'accepter
if (blockchainHash != computedHash) {
  throw 'Acte falsifié!';
}
```

---

## 🧪 Tests (Structure prête)

### Tests unitaires
```dart
// lib/services/hash_service_test.dart
test('HashService generates consistent hash', () {
  final hash1 = HashService.generateActeHash(id, date);
  final hash2 = HashService.generateActeHash(id, date);
  expect(hash1, equals(hash2));
});
```

### Tests de widget
```dart
// lib/screens/role_selector_screen_test.dart
testWidgets('RoleSelectorScreen displays 3 cards', (tester) {
  await tester.pumpWidget(const RoleSelectorScreen());
  expect(find.byType(_RoleCard), findsWidgets(3));
});
```

---

## 🚀 Optimisations futures

### 1. Base de données
```dart
// Actuellement: Map en mémoire
// À faire: SQLite, Hive, ou Firebase Firestore

// Example avec Hive
final box = await Hive.openBox('actes');
box.put(acte.id, acte.toJson());
```

### 2. Encryption
```dart
// À ajouter: EncryptedSharedPreferences
encrypted_shared_preferences: ^2.0.0

// Stockage sécurisé des données sensibles
```

### 3. Analytics
```dart
// À ajouter: Firebase Analytics
firebase_analytics: ^latest

// Suivre les événements
analytics.logEvent(name: 'acte_created', parameters: {...});
```

### 4. Notifications
```dart
// À ajouter: flutter_local_notifications
flutter_local_notifications: ^latest

// Notifier l'utilisateur
flutterLocalNotificationsPlugin.show(...);
```

---

## 📊 Comparaison avec alternatives

### State Management
| Solution | Complexité | Performance | Communauté |
|----------|-----------|-------------|-----------|
| Provider | Basse | Excellente | Grande |
| GetX | Basse | Excellente | Grande |
| Bloc | Moyenne | Excellente | Grande |
| Riverpod | Moyenne | Excellente | Moyenne |

**Choix**: Provider = Excellent pour hackathon

### Crypto
| Library | Algo | Sécurité | Perf |
|---------|-----|---------|------|
| crypto | SHA-256 | ✅ | Rapide |
| pointycastle | Multiple | ✅ | Rapide |
| flutter_secure_storage | Native | ✅ | Très rapide |

**Choix**: crypto = Simple et efficace

---

## 🔧 Configuration recommandée

### IDE: VS Code
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.enableSdkFormatter": true,
  "editor.formatOnSave": true
}
```

### IDE: Android Studio
```
- Install Flutter plugin
- Install Dart plugin
- Configure Flutter SDK
```

### Linters
```yaml
# analysis_options.yaml
linter:
  rules:
    - prefer_const_declarations
    - prefer_const_constructors
    - unnecessary_const
```

---

## 📈 Performance

### Benchmarks attendus
```
- Enregistrement acte: <500ms
- Vérification blockchain: <200ms
- Recherche: <300ms
- Navigation entre écrans: <100ms
```

### Optimization tips
```dart
// 1. Usar const constructors
const Widget(...) // Recyclé

// 2. Lazy loading
ListView.builder() // Seulement items visibles

// 3. Pagination
loadMore() // Charger à la demande

// 4. Caching
_cachedResults = ...
```

---

## 🌐 Déploiement

### PlayStore (Android)
```bash
# Build release
flutter build apk --release

# Ou AAB pour PlayStore
flutter build appbundle --release

# Signer l'app
jarsigner -keystore ~/key.jks build/app/outputs/app-release.apk
```

### AppStore (iOS)
```bash
# Build release
flutter build ios --release

# Archive avec Xcode
open ios/Runner.xcworkspace
# Product > Archive
```

### Firebase Hosting (Web)
```bash
# Build web
flutter build web --release

# Deploy
firebase deploy --only hosting
```

---

## 🎓 Ressources d'apprentissage

### Cours
- [Flutter Bootcamp](https://udemy.com/flutter-bootcamp)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Google Codelab](https://codelabs.developers.google.com)

### Communauté
- [r/Flutter](https://reddit.com/r/flutter)
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow Tag: flutter](https://stackoverflow.com/questions/tagged/flutter)

### Blogs
- [Flutter Medium](https://medium.com/flutter)
- [Filledstacks](https://www.filledstacks.com)
- [Codepoint](https://codepoint.medium.com)

---

## 🐛 Common Issues & Solutions

### Issue: Provider not found
```
Solution: Ensure MultiProvider wraps MaterialApp
File: lib/main.dart
```

### Issue: SHA-256 not working
```
Solution: Import crypto package correctly
Import: import 'package:crypto/crypto.dart';
```

### Issue: UUID conflicts
```
Solution: UUIDs are 99.99% unique. For local use, combine with timestamp
Example: '$uuid-${DateTime.now().millisecondsSinceEpoch}'
```

### Issue: Performance slow
```
Solution: 
- flutter run --release
- Use const constructors
- Enable tree shaking
```

---

## ✅ Checklist d'intégration

Quand vous voulez ajouter une nouvelle feature:

- [ ] Créer le modèle dans `lib/models/`
- [ ] Créer le service dans `lib/services/`
- [ ] Créer l'écran dans `lib/screens/`
- [ ] Enregistrer le service dans `lib/main.dart`
- [ ] Ajouter la route de navigation
- [ ] Tester le flow complet
- [ ] Documenter dans les commentaires

---

## 📞 Support

### Documentation du projet
- [IMPLEMENTATION.md](./IMPLEMENTATION.md) - Installation et utilisation
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Architecture technique
- [QUICKSTART.md](./QUICKSTART.md) - Démarrage rapide
- [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) - Contexte du projet

### Ressources officielles
- [Flutter.dev](https://flutter.dev)
- [Pub.dev](https://pub.dev) - Package registry
- [GitHub Discussions](https://github.com/flutter/flutter/discussions)

---

## 🎉 Vous êtes prêt!

Vous avez maintenant une application Flutter complète et fonctionnelle!

**Prochaine étape**: 
```bash
flutter pub get
flutter run
```

---

*NaissanceChain - Hackathon MIABE 2026*
