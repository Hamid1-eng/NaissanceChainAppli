// lib/services/qr_service.dart
// Service QR Code pour NaissanceChain
// IMPORTANT: Le QR code ne contient QUE l'ID de l'acte, pas de données personnelles

import 'package:uuid/uuid.dart';

class QRService {
  /// Génère un nouvel identifiant unique pour un acte de naissance
  /// Format: GN-YYYY-XXXXXXXX (Guinée-Année-8caractères hex/alphanum)
  static String generateActeId() {
    final now = DateTime.now();
    final year = now.year;

    // Génère un UUID court
    const uuid = Uuid();
    final shortUuid = uuid
        .v4()
        .replaceAll('-', '')
        .substring(0, 8)
        .toUpperCase();

    return 'GN-$year-$shortUuid';
  }

  /// Crée le contenu pour un QR code
  /// SECURITE: Contient UNIQUEMENT l'ID, jamais de données personnelles
  static String generateQRContent(String acteId) {
    // Format simple: juste l'ID
    // La vérification se fera en cherchant cet ID dans Firebase
    return acteId;
  }

  /// Valide qu'un contenu QR est un ID d'acte valide
  static bool isValidQRContent(String content) {
    // Format: GN-YYYY-XXXXXXXX
    final pattern = RegExp(r'^GN-\d{4}-[A-Z0-9]{8}$');
    return pattern.hasMatch(content);
  }

  /// Extrait l'ID de l'acte depuis un contenu QR
  static String? extractActeId(String qrContent) {
    if (isValidQRContent(qrContent)) {
      return qrContent;
    }
    return null;
  }

  /// Génère une URL de vérification (pourrait être utilisée pour un QR)
  /// Format: naissancechain://verify/ID
  static String generateVerificationUrl(String acteId) {
    return 'naissancechain://verify/$acteId';
  }

  /// Informations de sécurité
  static String getSecurityInfo() {
    return '''
SECURITÉ DES QR CODES:
- Le QR code contient UNIQUEMENT l'identifiant de l'acte
- Aucune données personnelle n'est encodée
- La vérification se fait en recherchant cet ID dans la base de données
- Seules les données de vérification (hash, timestamp) sont comparées
- Les données personnelles restent confidentielles
    ''';
  }
}
