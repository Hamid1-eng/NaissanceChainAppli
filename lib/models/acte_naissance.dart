// lib/models/acte_naissance.dart
// Modèle représentant un acte de naissance
// Les données personnelles sont stockées HORS blockchain dans Firebase
// La blockchain stocke uniquement la preuve (hash + timestamp)

class ActeNaissance {
  final String id; // Identifiant unique de l'acte

  // Informations de l'enfant
  final String nomEnfant;
  final String prenomEnfant;
  final DateTime dateNaissance;
  final String lieuNaissance;
  final String? empreinteEnfant;

  // Informations de la mère
  final String nomMere;
  final String prenomMere;
  final String? professionMere;
  final String ninMere;
  final String? nationaliteMere;
  final DateTime? dateNaissanceMere;

  // Informations du père (optionnelles)
  final String? nomPere;
  final String? prenomPere;
  final String? professionPere;
  final String ninPere;
  final String? nationalitePere;
  final DateTime? dateNaissancePere;

  // Localisation administrative
  final String? ville;
  final String? secteur;

  // Agent qui a enregistré la naissance
  final String agentName;
  final DateTime dateEnregistrement;

  // Informations blockchain (preuve d’existence)
  // Hash SHA-256 de l’acte (ID + date d’enregistrement)
  final String? blockchainHash;
  final String? blockchainTimestamp;
  final bool isBlockchainVerified;

  ActeNaissance({
    required this.id,
    required this.nomEnfant,
    required this.prenomEnfant,
    required this.dateNaissance,
    required this.lieuNaissance,
    this.empreinteEnfant,
    required this.nomMere,
    required this.prenomMere,
    this.professionMere,
    this.ninMere = 'NA',
    this.nationaliteMere,
    this.dateNaissanceMere,
    this.nomPere,
    this.prenomPere,
    this.professionPere,
    this.ninPere = 'NA',
    this.nationalitePere,
    this.dateNaissancePere,
    this.ville,
    this.secteur,
    required this.agentName,
    required this.dateEnregistrement,
    this.blockchainHash,
    this.blockchainTimestamp,
    this.isBlockchainVerified = false,
  });

  /// Convertit l'objet en JSON pour le stockage Firebase (hors-chaîne)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomEnfant': nomEnfant,
      'prenomEnfant': prenomEnfant,
      'dateNaissance': dateNaissance.toIso8601String(),
      'lieuNaissance': lieuNaissance,
      'empreinteEnfant': empreinteEnfant,
      'nomMere': nomMere,
      'prenomMere': prenomMere,
      'professionMere': professionMere,
      'ninMere': ninMere,
      'nationaliteMere': nationaliteMere,
      'dateNaissanceMere': dateNaissanceMere?.toIso8601String(),
      'nomPere': nomPere,
      'prenomPere': prenomPere,
      'professionPere': professionPere,
      'ninPere': ninPere,
      'nationalitePere': nationalitePere,
      'dateNaissancePere': dateNaissancePere?.toIso8601String(),
      'ville': ville,
      'secteur': secteur,
      'agentName': agentName,
      'dateEnregistrement': dateEnregistrement.toIso8601String(),
      'blockchainHash': blockchainHash,
      'blockchainTimestamp': blockchainTimestamp,
      'isBlockchainVerified': isBlockchainVerified,
    };
  }

  /// Crée un objet ActeNaissance à partir de JSON (Firebase)
  factory ActeNaissance.fromJson(Map<String, dynamic> json) {
    return ActeNaissance(
      id: json['id'] ?? '',
      nomEnfant: json['nomEnfant'] ?? '',
      prenomEnfant: json['prenomEnfant'] ?? '',
      dateNaissance: DateTime.parse(
        json['dateNaissance'] ?? DateTime.now().toIso8601String(),
      ),
      lieuNaissance: json['lieuNaissance'] ?? '',
      empreinteEnfant: json['empreinteEnfant'],
      nomMere: json['nomMere'] ?? '',
      prenomMere: json['prenomMere'] ?? '',
      professionMere: json['professionMere'],
      ninMere: json['ninMere'] ?? 'NA',
      nationaliteMere: json['nationaliteMere'],
      dateNaissanceMere: json['dateNaissanceMere'] != null
          ? DateTime.parse(json['dateNaissanceMere'])
          : null,
      nomPere: json['nomPere'],
      prenomPere: json['prenomPere'],
      professionPere: json['professionPere'],
      ninPere: json['ninPere'] ?? 'NA',
      nationalitePere: json['nationalitePere'],
      dateNaissancePere: json['dateNaissancePere'] != null
          ? DateTime.parse(json['dateNaissancePere'])
          : null,
      ville: json['ville'],
      secteur: json['secteur'],
      agentName: json['agentName'] ?? '',
      dateEnregistrement: DateTime.parse(
        json['dateEnregistrement'] ?? DateTime.now().toIso8601String(),
      ),
      blockchainHash: json['blockchainHash'],
      blockchainTimestamp: json['blockchainTimestamp'],
      isBlockchainVerified: json['isBlockchainVerified'] ?? false,
    );
  }

  /// Donnée du QR code
  /// IMPORTANT : le QR code contient UNIQUEMENT l'ID de l'acte
  String getQRCodeData() => id;

  /// Données minimales pour la vérification (sans données personnelles)
  Map<String, String> getVerificationData() {
    return {
      'id': id,
      'blockchainHash': blockchainHash ?? 'N/A',
      'blockchainTimestamp': blockchainTimestamp ?? 'N/A',
      'isVerified': isBlockchainVerified ? 'Oui' : 'Non',
    };
  }
}
