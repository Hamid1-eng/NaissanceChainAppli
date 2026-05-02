// lib/services/hash_service.dart
// Service de hachage SHA-256 pour les actes de naissance
// La blockchain n'enregistre que ce hash, jamais les données personnelles

import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashService {
  /// Génère un hash SHA-256 à partir des données de l'acte
  /// IMPORTANT: Ne hache que l'ID et la date (pas de données personnelles)
  /// pour une sécurité maximale
  static String generateActeHash(String acteId, DateTime dateEnregistrement) {
    // Combinaison simple mais unique pour chaque acte
    final data = '$acteId|${dateEnregistrement.toIso8601String()}';
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Génère un hash pour l'horodatage (timestamp)
  /// Utilisé pour garantir l'ordre chronologique sur la blockchain
  static String generateTimestampHash(DateTime timestamp) {
    return sha256.convert(utf8.encode(timestamp.toIso8601String())).toString();
  }

  /// Vérifie qu'un hash correspond aux données
  static bool verifyHash(String acteId, DateTime dateEnregistrement, String expectedHash) {
    final computedHash = generateActeHash(acteId, dateEnregistrement);
    return computedHash == expectedHash;
  }

  /// Génère un hash combiné pour la blockchain
  /// Inclut l'ID, le timestamp et crée une preuve unique
  static String generateBlockchainProof(String acteId, DateTime dateEnregistrement) {
    final acteHash = generateActeHash(acteId, dateEnregistrement);
    final timestampHash = generateTimestampHash(dateEnregistrement);
    final combined = '$acteHash|$timestampHash';
    return sha256.convert(utf8.encode(combined)).toString();
  }
}
