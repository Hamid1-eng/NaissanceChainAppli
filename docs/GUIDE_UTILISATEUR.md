# Guide utilisateur — Carte Guinée (NaissanceChain)

Ce guide explique en détail comment utiliser, vérifier et ajuster la carte interactive de la Guinée intégrée dans l'application NaissanceChain. Il est destiné aux développeurs et aux opérateurs qui doivent : lancer l'app, vérifier la carte, ajuster les marqueurs (Conakry, Boké, ...), et comprendre la colorisation dynamique des régions.

**Contenu**
- Introduction
- Prérequis
- Lancer l'application
- Fichiers importants
- Intégration du SVG
- Colorisation dynamique des régions
- Positionnement des marqueurs (pins)
- Ajustements fins (micro-ajustements)
- Hot reload & debug
- Dépannage courant
- Suggestions pour automatisation
- Bonnes pratiques & commits

---

## Introduction
La carte affichée sur le tableau de bord est une image SVG (`assets/maps/guinea_regions.svg`) rendue via `flutter_svg`. Les régions sont colorisées dynamiquement selon les données (nombre d'actes) et des marqueurs (pins) sont positionnés manuellement par des `Offset(dx,dy)` relatifs à la taille du conteneur.

## Prérequis
- Flutter SDK (v3.x ou ultérieur recommandé)
- `flutter_svg` et `xml` dans le `pubspec.yaml` (dépendances déjà ajoutées)
- Projet ouvert dans VS Code ou un IDE compatible

## Lancer l'application (rapide)
Ouvrir une console à la racine du projet puis :

```bash
flutter pub get
flutter run -d chrome
```

Pour appliquer un changement de code en cours d'exécution, utilisez le hot reload avec `r` dans la console où `flutter run` est lancée.

## Fichiers importants
- Widget principal de la carte : [lib/widgets/guinea_interactive_map.dart](lib/widgets/guinea_interactive_map.dart)
- SVG des régions : `assets/maps/guinea_regions.svg`
- `pubspec.yaml` : configuration des assets et dépendances

Consultez le widget pour comprendre la logique de rendu, la colorisation et le positionnement des marqueurs.

## Intégration du SVG
Le SVG est placé dans `assets/maps/guinea_regions.svg`. Le widget charge le fichier avec `rootBundle.loadString(...)`, le parse avec le package `xml` et injecte un attribut `fill` sur les éléments `<path>` correspondant aux régions.

Points clés :
- Si `_coloredSvg` est disponible, le widget utilise `SvgPicture.string(_coloredSvg!)` pour afficher la version colorisée.
- Sinon il tombe en back-up sur `SvgPicture.asset('assets/maps/guinea_regions.svg')`.

## Colorisation dynamique des régions
La logique :
1. Le widget calcule un `hex` de couleur pour chaque marqueur selon le nombre d'actes / taux.
2. Il normalise les noms et recherche les `path` du SVG par `title` ou par `id` partiellement correspondant.
3. Il injecte `fill="#rrggbb"` sur le `<path>` détecté.

Conseils :
- Pour fiabiliser la correspondance, assurez-vous que les `id` ou `title` dans le SVG contiennent le nom de la région (ex. `id="region_conakry"` ou `title="Conakry"`).
- Si le SVG est modifié, relancer la méthode `_loadAndColorizeSvg()` (elle est appelée à `initState` et `didUpdateWidget` lorsque `counts` change).

## Positionnement des marqueurs (pins)
Les marqueurs sont définis dans une liste `_markers` dans le widget :

- Fichier : [lib/widgets/guinea_interactive_map.dart](lib/widgets/guinea_interactive_map.dart)
- Exemple d'entrée :

```dart
_PrefectureMarkerSpec(displayName: 'Conakry', position: Offset(0.12, 0.45)),
```

Explication :
- `position.dx` et `position.dy` sont des valeurs normalisées entre 0 et 1 représentant la fraction de la largeur/hauteur du conteneur (ex. `dx=0.12` signifie 12% de la largeur depuis la gauche).
- Le widget calcule `left = marker.position.dx * width - 17` et `top = marker.position.dy * height - 34`, puis applique un clamp pour garder le marker à l'intérieur de la zone visible.

Pour déplacer un marqueur :
1. Ouvrir [lib/widgets/guinea_interactive_map.dart](lib/widgets/guinea_interactive_map.dart).
2. Modifier la ligne `Offset(...)` correspondante.
3. Sauvegarder et faire `r` (hot reload) pour voir le changement.

Exemple : déplacer Conakry vers la droite de 0.01 :

```dart
// Avant
_PrefectureMarkerSpec(displayName: 'Conakry', position: Offset(0.12, 0.45)),
// Après
_PrefectureMarkerSpec(displayName: 'Conakry', position: Offset(0.13, 0.45)),
```

## Ajustements fins (micro-ajustements)
- Pour des décalages très précis, utilisez des incréments de `0.005` à `0.02` selon la sensibilité du rendu.
- Workflow recommandé :
  1. Modifier `Offset(dx,dy)`.
  2. Presser `r` dans la console Flutter (hot reload).
  3. Vérifier visuellement et répéter.

Si tu fournis des captures annotées (comme tu l'as déjà fait), indique la direction (gauche/droite/haut/bas) et un incrément, et j'appliquerai les changements.

## Hot reload & debug
- Démarrer :

```bash
flutter run -d chrome
```

- Hot reload : dans la console où `flutter run` tourne, tapez `r`.
- Hot restart : tapez `R` (recompile toute l'applicaton state reset).
- Logs : surveille la console pour erreurs lors du parsing du SVG.

## Dépannage courant
- Problème : `SvgPicture.string` n'affiche rien après modification
  - Vérifier qu'il n'y a pas d'erreurs lors du parse XML (`_loadAndColorizeSvg()` capture les exceptions). Ouvrir la console pour voir l'erreur.
  - Vérifier que le SVG contient des `<path>` avec `id` ou `title` attendus.
- Problème : marqueur hors de la carte
  - Contrôler les bornes `clamp(6.0, width - 40.0)` et logique de calcul `-17/-34` qui positionne l'icône.
- Problème : couleur non appliquée
  - Vérifier la normalisation des noms dans `_normalizeKey` et l'existence des clefs dans `widget.counts`.

## Suggestions pour automatisation (optionnel)
- Calculer automatiquement le centroïde de chaque `<path>` SVG et positionner les marqueurs à ces centroïdes (meilleure précision que le positionnement manuel). Cela demande :
  - Extraire les commandes `d` des paths et calculer un centroïde (bibliothèques JS/Python existent, ou écrire un parseur Dart pour commands `M,L,C` ...).
  - Stocker un mapping `svgPathId -> Offset(normalizedX, normalizedY)` et le charger au runtime.

## Bonnes pratiques & commits
- Créer une branche pour chaque ajustement visuel (ex. `feat/map-conakry-placement`).
- Commit clair : "fix(map): reposition Conakry to match reference".
- Inclure captures écran dans la PR pour valider visuellement.

## Ressources utiles
- Widget : [lib/widgets/guinea_interactive_map.dart](lib/widgets/guinea_interactive_map.dart)
- Assets SVG : `assets/maps/guinea_regions.svg`

---

Si tu veux, je peux :
- Générer un script/outil pour calculer automatiquement les centroïdes des paths et produire un fichier JSON de positions.
- Commiter ce guide et créer une branche/PR.
- Appliquer un micro-ajustement précis pour `Conakry` si tu m'indiques la direction et la valeur.

Fin du guide.
