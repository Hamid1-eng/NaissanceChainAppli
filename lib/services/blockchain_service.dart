// lib/services/blockchain_service.dart
// Service blockchain pour NaissanceChain
// Enregistre UNIQUEMENT: ID de l'acte, hash SHA-256, et timestamp
// JAMAIS de données personnelles sur la blockchain

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'hash_service.dart';

class BlockchainRecord {
  final String acteId;
  final String hash; // Hash SHA-256 de l'acte
  final String timestamp; // ISO 8601 du timestamp
  final DateTime recordedAt;

  BlockchainRecord({
    required this.acteId,
    required this.hash,
    required this.timestamp,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'acteId': acteId,
      'hash': hash,
      'timestamp': timestamp,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory BlockchainRecord.fromJson(Map<String, dynamic> json) {
    return BlockchainRecord(
      acteId: json['acteId'] ?? '',
      hash: json['hash'] ?? '',
      timestamp: json['timestamp'] ?? '',
      recordedAt: DateTime.parse(
        json['recordedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class BlockchainService extends ChangeNotifier {
  /// Simulation locale de la blockchain (en produit, ce serait une blockchain réelle)
  /// Pour le hackathon, on stocke en mémoire et en SharedPreferences
  final List<BlockchainRecord> _records = [];

  List<BlockchainRecord> get records => List.unmodifiable(_records);

  /// Enregistre un acte sur la blockchain
  /// IMPORTANT: Ne stocke que l'ID et le hash, jamais les données personnelles
  Future<bool> recordActe(String acteId, DateTime dateEnregistrement) async {
    try {
      // Génère le hash de preuve
      final proof = HashService.generateBlockchainProof(
        acteId,
        dateEnregistrement,
      );

      // Crée l'enregistrement blockchain
      final record = BlockchainRecord(
        acteId: acteId,
        hash: proof,
        timestamp: dateEnregistrement.toIso8601String(),
        recordedAt: DateTime.now(),
      );

      // Ajoute à la chaîne locale
      _records.add(record);

      // Simule la validation (réduit pour éviter le gel UI)
      await Future.delayed(const Duration(milliseconds: 300));

      notifyListeners();
      debugPrint('✓ Blockchain: Acte $acteId enregistré');
      return true;
    } catch (e) {
      debugPrint('Erreur blockchain: $e');
      return false;
    }
  }

  /// Vérifie qu'un acte est enregistré sur la blockchain
  bool verifyActe(String acteId, String acteHash) {
    try {
      final record = _records.firstWhere((r) => r.acteId == acteId);

      // Comparaison hash ↔ hash (même type)
      return record.hash == acteHash;
    } catch (e) {
      return false;
    }
  }

  /// Retourne l'enregistrement blockchain d'un acte
  BlockchainRecord? getRecord(String acteId) {
    try {
      return _records.firstWhere((r) => r.acteId == acteId);
    } catch (e) {
      return null;
    }
  }

  /// Retourne l'historique complet (à des fins d'audit)
  List<BlockchainRecord> getAuditTrail() => List.unmodifiable(_records);

  /// Exporte les enregistrements en JSON (pour sauvegarde)
  String exportToJson() {
    final jsonList = _records.map((r) => r.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Importe les enregistrements depuis JSON (pour restauration)
  Future<void> importFromJson(String jsonString) async {
    try {
      final jsonList = jsonDecode(jsonString) as List;
      _records.clear();
      for (var item in jsonList) {
        _records.add(BlockchainRecord.fromJson(item));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur import blockchain: $e');
    }
  }

  /// Statistiques blockchain
  Map<String, dynamic> getStats() {
    return {
      'totalRecords': _records.length,
      'firstRecord': _records.isNotEmpty ? _records.first.recordedAt : null,
      'lastRecord': _records.isNotEmpty ? _records.last.recordedAt : null,
    };
  }
}
