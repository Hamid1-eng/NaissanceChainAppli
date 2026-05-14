# 🗺️ Carte Interactive de la Guinée - Guide d'Utilisation

## Vue d'ensemble

Le widget `GuineaInteractiveMap` affiche une carte stylisée de la Guinée avec 8 zones (préfectures) cliquables, reliée aux données Firestore en temps réel.

## Structure du Fichier

```
lib/widgets/guinea_interactive_map.dart
├── GuineaInteractiveMap (Widget principal)
├── _InteractiveMapZone (Zones cliquables)
├── _PrefectureDetailsModal (Modal au clic)
├── _StatBox (Statistiques)
├── _LegendChip (Légende)
├── _InstitutionalCartouche (En-tête institutionnel)
├── _GuineaOutlinePainter (CustomPaint contour)
└── _GuineaSilhouetteClipper (CustomClipper)
```

## Utilisation

### Import
```dart
import '../widgets/guinea_interactive_map.dart';
```

### Intégration dans Dashboard
```dart
GuineaInteractiveMap(
  prefectures: _prefectures,          // List<String>
  counts: counts,                      // Map<String, int>
  maxCount: maxCount,                  // int
  statusForRate: _statusForRate,       // Function(double) -> String
  statusColor: _statusColor,           // Function(String) -> Color
  formatPercent: _formatPercent,       // Function(double) -> String
)
```

### Paramètres

| Paramètre | Type | Description |
|-----------|------|-------------|
| `prefectures` | `List<String>` | Liste des 8 préfectures: ['Conakry', 'Kindia', 'Labé', ...] |
| `counts` | `Map<String, int>` | Nombre d'actes par préfecture {'Conakry': 42, ...} |
| `maxCount` | `int` | Nombre max d'actes (pour calcul du taux) |
| `statusForRate` | `Function` | Retourne 'Bon'/'Moyen'/'Faible' selon taux |
| `statusColor` | `Function` | Retourne Color selon statut |
| `formatPercent` | `Function` | Formate le pourcentage (ex: "85.5%") |

## Zones Interactives

### Positionnement (8 préfectures)
```
Zone 0: Conakry      → Position(16, 16) - Nord-Ouest
Zone 1: Kindia       → Position(10, 78) - Ouest
Zone 2: Labé         → Position(102, 72) - Nord-Est
Zone 3: Kankan       → Position(200, 96) - Est
Zone 4: N'Zérékoré  → Position(26, 154) - Centre-Sud
Zone 5: Boké        → Position(200, 170) - Sud-Est
Zone 6: Mamou       → Position(58, 244) - Centre
Zone 7: Faranah     → Position(112, 276) - Sud
```

### Interactions

#### Hover (Desktop)
```dart
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  cursor: SystemMouseCursors.click,
)
```

**Effets visibles:**
- Opacité augmente (alpha: 0.22 → 0.32)
- Border épaissit (1.4px → 2.0px)
- Shadow agrandit (blurRadius: 12 → 16)
- Cursor change → 🖱️ click

#### Clic
```dart
GestureDetector(
  onTap: () => widget.onTap(widget.zone.prefecture),
)
```

**Résultat:**
- Affiche modal bottom sheet
- Contient détails préfecture
- Statistiques et statut colorés

## Code Couleur

### Dynamique selon Taux

```dart
_statusForRate(double rate) {
  if (rate >= 70) return 'Bon';      // Vert  #16A34A
  if (rate >= 35) return 'Moyen';    // Jaune #F59E0B
  return 'Faible';                    // Rouge #DC2626
}

_statusColor(String status) {
  switch (status) {
    case 'Bon':    return const Color(0xFF16A34A);
    case 'Moyen':  return const Color(0xFFF59E0B);
    default:       return const Color(0xFFDC2626);
  }
}
```

### Cas "Sans données"
- **Couleur**: Gris (#CBD5E1)
- **Condition**: count == 0
- **Affichage**: "Neutre" au lieu de statut

## Modal Bottom Sheet

### Contenu

```
┌─────────────────────────────┐
│ ∼ (poignée)                 │
├─────────────────────────────┤
│ 📍 Préfecture               │
│    Nom de la préfecture     │
├─────────────────────────────┤
│ Actes     │ Taux            │
│ 42        │ 85.5%           │
├─────────────────────────────┤
│ Statut: ● Bon               │
├─────────────────────────────┤
│ [Fermer] [Détails complets] │
└─────────────────────────────┘
```

### État Modal

```dart
class _PrefectureDetailsModal extends StatelessWidget {
  final String prefecture;
  final int count;
  final double rate;
  final String status;
  final Color color;
}
```

## Données Firestore

### Collection: `actes_stats`

```json
{
  "id_acte": "NC-2026-ABC12345",
  "prefecture": "Conakry",
  "date_enregistrement": Timestamp(2026-04-30T14:30:00Z)
}
```

### Agrégation

```dart
// Dans FirebaseService
Future<Map<String, int>> getActesCountByPrefecture() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('actes_stats')
      .get();
  
  // Retourne: {'Conakry': 42, 'Kindia': 15, ...}
}
```

## Performance

### Rendering
- **Stack + Positioned**: Positionnement efficace
- **CustomPaint**: Contour Guinée dessiné une seule fois
- **CustomClipper**: Clipping optimisé
- **AnimatedContainer**: Animations 200ms smooth

### Memory
- Pas de requête Firestore répétée (mis en cache)
- Hover state local au widget
- Selection state au niveau de l'écran parent

### Offline
- FirebaseService stocke localement si pas connecté
- Données disponibles sans Internet
- Sync automatique si connexion

## Personnalisation

### Changer Couleurs

```dart
// Dans GuineaInteractiveMap
const Color(0xFF16A34A)  // Vert → votre couleur
const Color(0xFFF59E0B)  // Jaune → votre couleur
const Color(0xFFDC2626)  // Rouge → votre couleur
```

### Ajouter Zone Supplémentaire

```dart
// 1. Ajouter préfecture à liste
static const List<String> _prefectures = [
  'Conakry', ..., 'VotrePrefecture'
];

// 2. Ajouter _InteractiveMapZone dans Stack
_InteractiveMapZone(
  zone: zoneRows[8],
  position: const Rect.fromLTWH(x, y, width, height),
  onTap: _showPrefectureDetails,
  isSelected: _selectedPrefecture == zoneRows[8].prefecture,
),
```

### Modifier Tailles Zones

```dart
// Les positions utilisent Rect.fromLTWH(left, top, width, height)
// Adapter les valeurs selon votre besoin
position: const Rect.fromLTWH(16, 16, 200, 64)
```

## Fonctionnalités Avancées

### Ajouter Animations au Chargement

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Animation au chargement
  });
}
```

### Sync Real-time

```dart
// Écouter Firestore en temps réel
FirebaseFirestore.instance
    .collection('actes_stats')
    .snapshots()
    .listen((snapshot) {
  setState(() {
    // Mettre à jour counts
  });
});
```

### Export PDF

```dart
// Dans modal, ajouter bouton Export
ElevatedButton(
  onPressed: () => _exportPrefecturePDF(prefecture),
  child: const Text('Télécharger PDF'),
)
```

## Troubleshooting

### Les zones ne sont pas cliquables
- Vérifier les Positioned dans Stack
- Vérifier GestureDetector onTap n'est pas null
- Vérifier ClipPath n'occupe pas les zones

### Modal ne s'affiche pas
- Vérifier contexte NavigatorState
- Vérifier showModalBottomSheet() appel
- Vérifier pas d'erreur dans _showPrefectureDetails()

### Couleurs incorrectes
- Vérifier _statusColor() retourne Color valide
- Vérifier _statusForRate() retourne bon statut
- Vérifier code couleur hex valide

## Intégration Complète

```dart
// Dans national_dashboard_screen.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        children: [
          // ... KPIs et tableau ...
          _SectionCard(
            title: 'Carte de couverture nationale',
            child: GuineaInteractiveMap(
              prefectures: _prefectures,
              counts: counts,
              maxCount: maxCount,
              statusForRate: _statusForRate,
              statusColor: _statusColor,
              formatPercent: _formatPercent,
            ),
          ),
        ],
      ),
    ),
  );
}
```

## Contraintes

- ✅ Flutter uniquement
- ✅ Pas de Google Maps
- ✅ Pas de GPS
- ✅ Stack + Positioned uniquement
- ✅ Illustratif mais lié données réelles
- ✅ Offline-first
- ✅ Performance optimisée

## Tests

### Test Manuel
1. Accéder au dashboard national
2. Scroller jusqu'à "Carte de couverture nationale"
3. Tester hover sur zones (desktop)
4. Cliquer sur zone → modal s'affiche
5. Vérifier infos correctes dans modal
6. Tester code couleur (Bon/Moyen/Faible)
7. Rafraîchir dashboard → données mises à jour

### Cas Limites
- ✅ 0 actes en base (affiche Gris "Neutre")
- ✅ Pas de données Firestore (vide)
- ✅ Offline (utilise données en mémoire)
- ✅ Taux = 0% (Faible)
- ✅ Taux = 100% (Bon)

## Fichier Structure

```
lib/
├── screens/
│   └── national_dashboard_screen.dart (utilise widget)
├── widgets/
│   └── guinea_interactive_map.dart (le widget)
├── services/
│   └── firebase_service.dart (fournit données)
└── models/
    └── acte_naissance.dart
```

---

**Version**: 1.0  
**Date**: Mai 2026  
**Hackathon**: MIABE 2026 Finale  
**Projet**: NaissanceChain
