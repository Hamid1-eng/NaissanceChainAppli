// lib/services/firebase_service.dart
// Service Firebase pour stockage hors-chaîne
// Stocke UNIQUEMENT les données de naissance (pas de blockchain ici)
// Offline-first: peut fonctionner sans connexion Internet
// Firebase stocke l'état de vérification, la blockchain décide de l'authenticité

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/acte_naissance.dart';

class FirebaseService extends ChangeNotifier {
  /// Simulation Firebase avec une map en mémoire
  /// En production: utiliser Firebase Realtime Database ou Firestore
  final Map<String, ActeNaissance> _actes = {};

  /// Historique des naissances pour l'administration
  final List<ActeNaissance> _allActes = [];

  /// Historique local des écritures statistiques Firestore (fallback/offline)
  final List<Map<String, dynamic>> _actesStats = [];

  /// Retourne tous les actes pour l'agent (accès total)
  List<ActeNaissance> get allActes => List.unmodifiable(_allActes);

  /// Retourne un acte par son ID (depuis la map locale)
  ActeNaissance? getActe(String acteId) => _actes[acteId];

  /// 🔥 NOUVEAU: Récupère un acte par son ID depuis Firestore
  /// Aller chercher dans la collection "actes" avec persistance
  /// Retourne null si non trouvé
  Future<ActeNaissance?> getActeById(String acteId) async {
    try {
      // D'abord, vérifier la map locale (cache)
      if (_actes.containsKey(acteId)) {
        debugPrint('✓ Acte $acteId trouvé dans le cache local');
        return _actes[acteId];
      }

      // Si Firebase n'est pas initialisé, on ne peut rien faire
      if (Firebase.apps.isEmpty) {
        debugPrint('⚠ Firebase non initialisé, acte $acteId non trouvé');
        return null;
      }

      // Chercher dans Firestore collection "actes" avec acteId comme document ID
      final docSnapshot = await FirebaseFirestore.instance
          .collection('actes')
          .doc(acteId)
          .get();

      if (!docSnapshot.exists) {
        debugPrint('❌ Aucun acte trouvé pour $acteId dans Firestore');
        return null;
      }

      // Convertir le document en ActeNaissance
      final data = docSnapshot.data()!;
      final acte = ActeNaissance.fromJson(data);

      // Mettre en cache localement
      _actes[acteId] = acte;
      _allActes.add(acte);
      notifyListeners();

      debugPrint('✓ Firestore: Acte $acteId récupéré et mis en cache');
      return acte;
    } catch (e) {
      debugPrint('❌ Erreur Firebase getActeById: $e');
      return null;
    }
  }

  /// Enregistre une statistique minimale pour le tableau de bord national.
  /// Ne stocke aucune donnée personnelle.
  Future<bool> recordActeStat({
    required String idActe,
    required String prefecture,
    required DateTime dateEnregistrement,
  }) async {
    final payload = <String, dynamic>{
      'id_acte': idActe,
      'prefecture': prefecture,
      'date_enregistrement': Timestamp.fromDate(dateEnregistrement),
    };

    try {
      _actesStats.add(payload);

      if (Firebase.apps.isEmpty) {
        debugPrint(
          '✓ Firebase non initialisé: stat conservée localement pour actes_stats',
        );
        return true;
      }

      await FirebaseFirestore.instance.collection('actes_stats').add(payload);
      debugPrint('✓ Firestore: stat enregistrée dans actes_stats');
      return true;
    } catch (e) {
      debugPrint('Erreur Firebase recordActeStat: $e');
      return false;
    }
  }

  /// Compte les actes par préfecture à partir de `actes_stats`.
  /// Retourne un Map<String, int> avec la préfecture comme clé.
  Future<Map<String, int>> getActesCountByPrefecture() async {
    try {
      if (Firebase.apps.isEmpty) {
        return _aggregatePrefectureCounts(_actesStats);
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('actes_stats')
          .get();

      final rows = snapshot.docs
          .map((doc) => doc.data())
          .where((data) => data['prefecture'] != null)
          .toList();

      return _aggregatePrefectureCounts(rows);
    } catch (e) {
      debugPrint('Erreur Firebase getActesCountByPrefecture: $e');
      return {};
    }
  }

  Map<String, int> _aggregatePrefectureCounts(List<Map<String, dynamic>> rows) {
    final counts = <String, int>{};

    for (final row in rows) {
      final prefecture = row['prefecture'];
      if (prefecture is! String || prefecture.trim().isEmpty) {
        continue;
      }

      counts[prefecture] = (counts[prefecture] ?? 0) + 1;
    }

    return counts;
  }

  /// Crée un nouvel acte de naissance
  /// Stockage offline-first dans le cache local + Firestore collection "actes"
  Future<bool> createActe(ActeNaissance acte) async {
    try {
      if (acte.id.isEmpty) return false;

      // Stocker localement (offline-first)
      _actes[acte.id] = acte;
      _allActes.add(acte);

      // Simule légèrement la latence réseau (réduit pour éviter le gel)
      await Future.delayed(const Duration(milliseconds: 100));

      // Stocker dans Firestore collection "actes" avec acte.id comme document ID
      if (Firebase.apps.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('actes')
              .doc(acte.id)
              .set(acte.toJson());
          debugPrint(
            '✓ Firestore: Acte ${acte.id} stocké dans la collection actes',
          );
        } catch (e) {
          debugPrint(
            '⚠ Erreur lors de la sauvegarde Firestore: $e (données en cache)',
          );
        }
      }

      notifyListeners();
      debugPrint('✓ Firebase: Acte ${acte.id} créé (local + Firestore)');
      return true;
    } catch (e) {
      debugPrint('Erreur Firebase createActe: $e');
      return false;
    }
  }

  /// Met à jour un acte existant
  /// Mise à jour local + Firestore
  Future<bool> updateActe(ActeNaissance acte) async {
    try {
      if (!_actes.containsKey(acte.id)) return false;

      final index = _allActes.indexWhere((a) => a.id == acte.id);
      if (index >= 0) {
        _allActes[index] = acte;
      }
      _actes[acte.id] = acte;

      // Simule légèrement la latence réseau (réduit pour éviter le gel)
      await Future.delayed(const Duration(milliseconds: 100));

      // Mettre à jour dans Firestore
      if (Firebase.apps.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('actes')
              .doc(acte.id)
              .update(acte.toJson());
          debugPrint(
            '✓ Firestore: Acte ${acte.id} mis à jour dans la collection actes',
          );
        } catch (e) {
          debugPrint(
            '⚠ Erreur lors de la mise à jour Firestore: $e (données en cache)',
          );
        }
      }

      notifyListeners();
      debugPrint('✓ Firebase: Acte ${acte.id} mis à jour (local + Firestore)');
      return true;
    } catch (e) {
      debugPrint('Erreur Firebase updateActe: $e');
      return false;
    }
  }

  /// Recherche les actes d'une famille par nom de mère
  Future<List<ActeNaissance>> searchActesByMother(String nomMere) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _allActes
          .where(
            (acte) =>
                acte.nomMere.toLowerCase().contains(nomMere.toLowerCase()),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur Firebase searchActesByMother: $e');
      return [];
    }
  }

  /// Recherche par nom d'enfant
  Future<List<ActeNaissance>> searchActesByChild(String nomEnfant) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _allActes
          .where(
            (acte) =>
                acte.nomEnfant.toLowerCase().contains(
                  nomEnfant.toLowerCase(),
                ) ||
                acte.prenomEnfant.toLowerCase().contains(
                  nomEnfant.toLowerCase(),
                ),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur Firebase searchActesByChild: $e');
      return [];
    }
  }

  /// Retourne les actes enregistrés dans une période
  Future<List<ActeNaissance>> getActesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _allActes
          .where(
            (acte) =>
                acte.dateEnregistrement.isAfter(start) &&
                acte.dateEnregistrement.isBefore(end),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur Firebase getActesByDateRange: $e');
      return [];
    }
  }

  /// Retourne les actes d'un agent
  Future<List<ActeNaissance>> getActesByAgent(String agentName) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _allActes
          .where(
            (acte) => acte.agentName.toLowerCase() == agentName.toLowerCase(),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur Firebase getActesByAgent: $e');
      return [];
    }
  }

  /// Retourne les actes vérifiés sur la blockchain
  /// L'état est stocké ici, la décision vient de BlockchainService
  Future<List<ActeNaissance>> getVerifiedActes() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _allActes.where((acte) => acte.isBlockchainVerified).toList();
    } catch (e) {
      debugPrint('Erreur Firebase getVerifiedActes: $e');
      return [];
    }
  }

  /// Statistiques globales
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'totalActes': _allActes.length,
        'verifiedActes': _allActes.where((a) => a.isBlockchainVerified).length,
        'unverifiedActes': _allActes
            .where((a) => !a.isBlockchainVerified)
            .length,
        'withFather': _allActes.where((a) => a.nomPere != null).length,
        'withoutFather': _allActes.where((a) => a.nomPere == null).length,
      };
    } catch (e) {
      debugPrint('Erreur Firebase getStatistics: $e');
      return {};
    }
  }

  /// Exporte tous les actes en JSON (sauvegarde)
  String exportAllActes() {
    final jsonList = _allActes.map((a) => a.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Efface tous les actes (test/reset)
  Future<void> clearAllActes() async {
    _actes.clear();
    _allActes.clear();
    notifyListeners();
    debugPrint('✓ Tous les actes ont été effacés');
  }

  /// Nombre total d'actes
  int get acteCount => _allActes.length;
}
