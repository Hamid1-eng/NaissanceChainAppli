# 🚀 Quick Start - Dashboard Interactif

## 5 Minutes pour Découvrir la Carte Interactive

### 1️⃣ Lancer l'Application

```bash
cd d:\NaissanceChainApp\flutter_application_naissancechain
flutter run -d chrome
```

**OU sur mobile/émulateur:**
```bash
flutter run
```

### 2️⃣ Accéder au Dashboard

1. **Écran d'accueil** → Cliquer sur **"Accès administrateur"**
2. Sélectionner **"Tableau de bord national"**
3. Attendre le chargement des données

### 3️⃣ Découvrir la Carte

**Desktop** (Chrome):
- 🖱️ Survoler une zone → highlight + cursor change
- 🖱️ Cliquer une zone → modal détails s'affiche

**Mobile** (Émulateur/Téléphone):
- 👆 Appuyer sur zone → modal détails
- 📱 Swipe down pour rafraîchir

### 4️⃣ Lire les Détails du Modal

Le modal affiche :
```
📍 Nom Préfecture
├─ Actes: 42
├─ Taux: 85.5%
├─ Statut: Bon (🟢)
└─ [Fermer] [Détails complets]
```

### 5️⃣ Voir Code Couleur

Zones colorées selon taux :
- 🟢 **Vert** = Bon (≥70%)
- 🟡 **Jaune** = Moyen (35-69%)
- 🔴 **Rouge** = Faible (<35%)
- ⚪ **Gris** = Sans données

---

## 🧪 Tester les Fonctionnalités

### Tester Hover (Desktop)
```
1. Ouvrir dashboard
2. Survoler zone → Voir highlight
3. Vérifier opacité augmente
4. Vérifier border épaissit
5. Vérifier shadow agrandit
```

### Tester Clic
```
1. Cliquer zone Conakry
2. Vérifier modal s'affiche
3. Vérifier données correctes
4. Cliquer "Fermer"
5. Répéter avec autres zones
```

### Tester Refresh
```
1. Dashboard ouvert
2. Swipe down (mobile) OU Pull to refresh (web)
3. Vérifier données actualisées
4. Vérifier couleurs changent si données changent
```

### Tester Offline
```
1. Mode développeur (F12)
2. Network → Offline
3. Dashboard fonctionne toujours
4. Zones affichent données en cache
5. Modal reste fonctionnel
```

---

## 📱 Cas Limites à Tester

### Préfecture sans données
- Conakry avec 0 actes → Gris "Neutre"
- Vérifier modal affiche "N/A"
- Vérifier bouton "Détails complets" OK

### Taux min/max
- 0% → Faible (🔴)
- 100% → Bon (🟢)
- 50% → Moyen (🟡)

### Rafraîchir
- Données changent → Couleurs mises à jour
- Nombre augmente → Taux recalculé
- Statut s'ajuste

---

## 📊 Ajouter Données Test (Optionnel)

Pour peupler le dashboard avec données de test :

```dart
// Dans firebase_service.dart
Future<void> seedTestData() async {
  final stats = [
    {'prefecture': 'Conakry', 'count': 42},
    {'prefecture': 'Kindia', 'count': 15},
    {'prefecture': 'Labé', 'count': 8},
    {'prefecture': 'Kankan', 'count': 12},
    {'prefecture': 'N\'Zérékoré', 'count': 5},
    {'prefecture': 'Boké', 'count': 3},
    {'prefecture': 'Mamou', 'count': 22},
    {'prefecture': 'Faranah', 'count': 10},
  ];
  
  for (final stat in stats) {
    await recordActeStat(
      idActe: 'TEST-${stat["prefecture"]}',
      prefecture: stat['prefecture'] as String,
      dateEnregistrement: DateTime.now(),
    );
  }
}
```

---

## 🔧 Commandes Utiles

### Lancer les tests
```bash
flutter test test/dashboard_interactive_map_test.dart
```

### Analyser code
```bash
flutter analyze
```

### Nettoyer build
```bash
flutter clean
flutter pub get
```

### Débugger
```bash
flutter run --verbose
```

---

## 🎨 Personaliser

### Changer Couleurs
Éditer `lib/widgets/guinea_interactive_map.dart` :
```dart
const Color(0xFF16A34A)  // Vert → votre couleur
const Color(0xFFF59E0B)  // Jaune → votre couleur
const Color(0xFFDC2626)  // Rouge → votre couleur
```

### Modifier Positions Zones
Éditer `lib/widgets/guinea_interactive_map.dart` :
```dart
_InteractiveMapZone(
  zone: zoneRows[0],
  position: const Rect.fromLTWH(16, 16, 200, 64),  // ← Modifier
```

### Ajouter Zone
1. Ajouter préfecture à liste
2. Créer nouvelle `_InteractiveMapZone`
3. Positionner avec `Rect.fromLTWH`

---

## 📋 Checklist Vérification

Avant de considérer comme "OK" :

- [ ] Dashboard charge sans erreur
- [ ] 8 zones visibles sur la carte
- [ ] Zones ont bonnes couleurs
- [ ] Survol zone change highlight (desktop)
- [ ] Clic zone ouvre modal
- [ ] Modal affiche préfecture, actes, taux
- [ ] Statut couleur correct
- [ ] Légende visible
- [ ] Refresh actualise données
- [ ] Offline fonctionne
- [ ] Tests passent (8/8)
- [ ] Aucune erreur console

---

## 🆘 Troubleshooting

### Les zones n'apparaissent pas
- Vérifier `_GuineaSilhouetteClipper` pas vide
- Vérifier Stack `fit: StackFit.expand`
- Vérifier `Positioned` n'a pas `display: none`

### Modal ne s'affiche pas
- Vérifier contexte NavigatorState
- Vérifier pas d'exception dans `_showPrefectureDetails()`
- Vérifier `showModalBottomSheet()` correct

### Couleurs incorrectes
- Vérifier `_statusForRate()` retourne bon statut
- Vérifier `_statusColor()` retourne bon Color
- Vérifier pas de cache (hot restart)

### Données vides
- Vérifier Firebase Service initialisé
- Vérifier données enregistrées précédemment
- Vérifier hors ligne (check mémoire locale)

---

## 📚 Documentation Complète

Pour plus de détails, voir:
- [DASHBOARD_INTERACTIVE_MAP_GUIDE.md](DASHBOARD_INTERACTIVE_MAP_GUIDE.md) - Guide complet
- [IMPLEMENTATION_DASHBOARD.md](IMPLEMENTATION_DASHBOARD.md) - Détails implémentation
- [CHANGELOG.md](CHANGELOG.md) - Historique v1.1.0
- [README.md](README.md) - Vue d'ensemble projet

---

## ⏱️ Timeline

```
5 min  → Lancer app + accéder dashboard
10 min → Explorer toutes zones + cliquer
15 min → Tester offline + refresh
20 min → Lire toute documentation
```

---

## 🎓 Points Clés

1. **Carte stylisée** sans complexité géographique
2. **Données réelles** depuis Firestore
3. **Interactivité complète** : clic + hover
4. **Offline-first** : marche sans Internet
5. **Code couleur** : Bon/Moyen/Faible/Neutre
6. **Modal détails** : nom, actes, taux
7. **Performance** : smooth 60 FPS
8. **Tests** : 8/8 passant

---

**Bon voyage sur NaissanceChain ! 🚀**

Version 1.1.0 | Mai 2026 | MIABE Hackathon 2026
