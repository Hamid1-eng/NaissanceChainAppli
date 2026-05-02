// lib/services/firebase_service.dart
// Service Firebase pour stockage hors-chaîne
// Stocke UNIQUEMENT les données de naissance (pas de blockchain ici)
// Offline-first: peut fonctionner sans connexion Internet
// Firebase stocke l'état de vérification, la blockchain décide de l'authenticité

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/acte_naissance.dart';

class FirebaseService extends ChangeNotifier {
  /// Simulation Firebase avec une map en mémoire
  /// En production: utiliser Firebase Realtime Database ou Firestore
  final Map<String, ActeNaissance> _actes = {};

  /// Historique des naissances pour l'administration
  final List<ActeNaissance> _allActes = [];

  /// Retourne tous les actes pour l'agent (accès total)
  List<ActeNaissance> get allActes => List.unmodifiable(_allActes);

  /// Retourne un acte par son ID
  ActeNaissance? getActe(String acteId) => _actes[acteId];

  /// Crée un nouvel acte de naissance
  /// Stockage offline-first dans le cache local
  Future<bool> createActe(ActeNaissance acte) async {
    try {
      if (acte.id.isEmpty) return false;

      _actes[acte.id] = acte;
      _allActes.add(acte);

      // Simule légèrement la latence réseau (réduit pour éviter le gel)
      await Future.delayed(const Duration(milliseconds: 100));

      notifyListeners();
      debugPrint('✓ Firebase: Acte ${acte.id} créé');
      return true;
    } catch (e) {
      debugPrint('Erreur Firebase createActe: $e');
      return false;
    }
  }

  /// Met à jour un acte existant
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

      notifyListeners();
      debugPrint('✓ Firebase: Acte ${acte.id} mis à jour');
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
          .where((acte) =>
              acte.nomMere.toLowerCase().contains(nomMere.toLowerCase()))
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
          .where((acte) =>
              acte.nomEnfant.toLowerCase().contains(nomEnfant.toLowerCase()) ||
              acte.prenomEnfant
                  .toLowerCase()
                  .contains(nomEnfant.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Erreur Firebase searchActesByChild: $e');
      return [];
    }
  }

  /// Retourne les actes enregistrés dans une période
  Future<List<ActeNaissance>> getActesByDateRange(
      DateTime start, DateTime end) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _allActes
          .where((acte) =>
              acte.dateEnregistrement.isAfter(start) &&
              acte.dateEnregistrement.isBefore(end))
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
          .where((acte) =>
              acte.agentName.toLowerCase() == agentName.toLowerCase())
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
        'verifiedActes':
            _allActes.where((a) => a.isBlockchainVerified).length,
        'unverifiedActes':
            _allActes.where((a) => !a.isBlockchainVerified).length,
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