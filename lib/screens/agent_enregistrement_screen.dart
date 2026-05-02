// Ecran pour l'enregistrement des naissances par les agents
// Capture les informations et genere l'identifiant unique

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/acte_naissance.dart';
import '../services/blockchain_service.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../services/firebase_service.dart';
import '../services/hash_service.dart';
import '../services/qr_service.dart';

class AgentEnregistrementScreen extends StatefulWidget {
  final String? agentName;

  const AgentEnregistrementScreen({super.key, this.agentName});

  @override
  State<AgentEnregistrementScreen> createState() =>
      _AgentEnregistrementScreenState();
}

class _AgentEnregistrementScreenState extends State<AgentEnregistrementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomEnfantController = TextEditingController();
  final _prenomEnfantController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _nomMereController = TextEditingController();
  final _prenomMereController = TextEditingController();
  final _nationaliteMereController = TextEditingController();
  final _dateNaissanceMereController = TextEditingController();
  final _professionMereController = TextEditingController();
  final _nomPereController = TextEditingController();
  final _prenomPereController = TextEditingController();
  final _nationalitePereController = TextEditingController();
  final _dateNaissancePereController = TextEditingController();
  final _professionPereController = TextEditingController();
  final _villeController = TextEditingController();
  final _secteurController = TextEditingController();

  String _acteId = '';
  bool _isSubmitting = false;
  DateTime? _dateNaissance;
  DateTime? _dateNaissanceMere;
  DateTime? _dateNaissancePere;

  @override
  void dispose() {
    _nomEnfantController.dispose();
    _prenomEnfantController.dispose();
    _dateNaissanceController.dispose();
    _nomMereController.dispose();
    _prenomMereController.dispose();
    _nationaliteMereController.dispose();
    _dateNaissanceMereController.dispose();
    _professionMereController.dispose();
    _nomPereController.dispose();
    _prenomPereController.dispose();
    _nationalitePereController.dispose();
    _dateNaissancePereController.dispose();
    _professionPereController.dispose();
    _villeController.dispose();
    _secteurController.dispose();
    super.dispose();
  }

  Future<void> _pickDateNaissance() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(2024, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _dateNaissance = pickedDate;
      _dateNaissanceController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _pickDateNaissanceMere() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateNaissanceMere ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance de la mère',
    );

    if (pickedDate == null) return;

    setState(() {
      _dateNaissanceMere = pickedDate;
      _dateNaissanceMereController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _pickDateNaissancePere() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateNaissancePere ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance du père',
    );

    if (pickedDate == null) return;

    setState(() {
      _dateNaissancePere = pickedDate;
      _dateNaissancePereController.text = _formatDate(pickedDate);
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nomEnfantController.clear();
    _prenomEnfantController.clear();
    _dateNaissanceController.clear();
    _nomMereController.clear();
    _nationaliteMereController.clear();
    _dateNaissanceMereController.clear();
    _professionMereController.clear();
    _nomPereController.clear();
    _nationalitePereController.clear();
    _dateNaissancePereController.clear();
    _professionPereController.clear();
    _villeController.clear();
    _secteurController.clear();
    _dateNaissance = null;
    _dateNaissanceMere = null;
    _dateNaissancePere = null;
    setState(() {
      _acteId = '';
    });
  }

  void _clearAndReset() {
    _resetForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulaire vidé.')),
    );
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir correctement tous les champs obligatoires.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final birthDate = _dateNaissance;
    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la date de naissance de l\'enfant.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('[AgentEnregistrement] 🔵 Début de la soumission');

      final firebaseService = context.read<FirebaseService>();
      final blockchainService = context.read<BlockchainService>();
      debugPrint('[AgentEnregistrement] ✓ Services récupérés');

      // Générer l'ID au moment de la soumission (une seule fois)
      setState(() {
        _acteId = QRService.generateActeId();
      });

      final dateEnregistrement = DateTime.now();
      final blockchainHash = HashService.generateBlockchainProof(
        _acteId,
        dateEnregistrement,
      );
      debugPrint('[AgentEnregistrement] ✓ Hash généré');

      final acte = ActeNaissance(
        id: _acteId,
        nomEnfant: _nomEnfantController.text.trim(),
        prenomEnfant: _prenomEnfantController.text.trim(),
        dateNaissance: birthDate,
        lieuNaissance:
            '${_villeController.text.trim()} - ${_secteurController.text.trim()}',
        empreinteEnfant: null,
        nomMere: _nomMereController.text.trim(),
        prenomMere: _prenomMereController.text.trim(),
        professionMere: _professionMereController.text.trim().isEmpty ? null : _professionMereController.text.trim(),
        ninMere: 'NA',
        nationaliteMere: _nationaliteMereController.text.trim().isEmpty ? null : _nationaliteMereController.text.trim(),
        dateNaissanceMere: _dateNaissanceMere,
        nomPere: _nomPereController.text.trim().isEmpty
            ? null
            : _nomPereController.text.trim(),
        prenomPere: _prenomPereController.text.trim().isEmpty
            ? null
            : _prenomPereController.text.trim(),
        professionPere: _professionPereController.text.trim().isEmpty
            ? null
            : _professionPereController.text.trim(),
        ninPere: 'NA',
        nationalitePere: _nationalitePereController.text.trim().isEmpty ? null : _nationalitePereController.text.trim(),
        dateNaissancePere: _dateNaissancePere,
        ville: _villeController.text.trim(),
        secteur: _secteurController.text.trim(),
        agentName: widget.agentName ?? 'Drame Moussa',
        dateEnregistrement: dateEnregistrement,
        blockchainHash: blockchainHash,
        blockchainTimestamp: dateEnregistrement.toIso8601String(),
        isBlockchainVerified: false,
      );
      debugPrint('[AgentEnregistrement] ✓ Acte créé: ${acte.id}');

      debugPrint('[AgentEnregistrement] ⏳ Enregistrement blockchain...');
      final blockchainSuccess = await blockchainService
          .recordActe(
            acte.id,
            dateEnregistrement,
          )
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () {
              debugPrint('[AgentEnregistrement] ⏱️ Timeout blockchain');
              return false;
            },
          );
      debugPrint('[AgentEnregistrement] ✓ Blockchain enregistrée: $blockchainSuccess');

      if (!blockchainSuccess) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La validation blockchain a expiré. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint('[AgentEnregistrement] ⏳ Sauvegarde Firebase...');
      final saved = await firebaseService
          .createActe(
            ActeNaissance(
              id: acte.id,
              nomEnfant: acte.nomEnfant,
              prenomEnfant: acte.prenomEnfant,
              dateNaissance: acte.dateNaissance,
              lieuNaissance: acte.lieuNaissance,
              empreinteEnfant: null,
              nomMere: acte.nomMere,
              prenomMere: acte.prenomMere,
              professionMere: acte.professionMere,
              ninMere: acte.ninMere,
              nationaliteMere: acte.nationaliteMere,
              dateNaissanceMere: acte.dateNaissanceMere,
              nomPere: acte.nomPere,
              prenomPere: acte.prenomPere,
              professionPere: acte.professionPere,
              ninPere: acte.ninPere,
              nationalitePere: acte.nationalitePere,
              dateNaissancePere: acte.dateNaissancePere,
              ville: acte.ville,
              secteur: acte.secteur,
              agentName: acte.agentName,
              dateEnregistrement: acte.dateEnregistrement,
              blockchainHash: acte.blockchainHash,
              blockchainTimestamp: acte.blockchainTimestamp,
              isBlockchainVerified: true,
            ),
          )
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () {
              debugPrint('[AgentEnregistrement] ⏱️ Timeout Firebase');
              return false;
            },
          );
      debugPrint('[AgentEnregistrement] ✓ Firebase sauvegardée: $saved');

      if (!mounted) {
        debugPrint('[AgentEnregistrement] ⚠️ Widget détruit pendant save');
        return;
      }

      if (saved) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        debugPrint('[AgentEnregistrement] 🎉 Retour succès affiché');
        
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 54),
                  SizedBox(height: 16),
                  Text(
                    'Acte enregistré\navec succès',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 22,
                      color: Color(0xFF0D1B2A),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'L\'acte a été sécurisé sur NaissanceChain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ID: ${acte.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D1B2A),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4EAF1), width: 2),
                      ),
                      child: BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        data: acte.id,
                        width: 140,
                        height: 140,
                        color: const Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'QR code de vérification',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _resetForm();
                    },
                    child: const Text(
                      'Fermer et créer un autre acte',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'enregistrer l\'acte pour le moment.'),
          ),
        );
        debugPrint('[AgentEnregistrement] ❌ Erreur: createActe retourné false');
      }
    } catch (e, stackTrace) {
      debugPrint('[AgentEnregistrement] ❌ Exception: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      stopwatch.stop();
      debugPrint(
        '[AgentEnregistrement] ⏱️ Durée totale soumission: ${stopwatch.elapsedMilliseconds}ms',
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    );
  }

  Widget _buildSectionCard({
    required Widget title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F7FB);
    const primaryBlue = Color(0xFF0D1B2A);
    const border = Color(0xFFD1D9E6);
    const muted = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Portail Agent',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.agentName ?? 'Agent de saisie',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: _AgentBadge(),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE4EAF1)),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enregistrement de\nNaissance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B1020),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Veuillez renseigner les informations légales\npour la création de l\'acte de naissance\nsécurisé sur la blockchain NaissanceChain.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 22),
                _buildSectionCard(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.child_care_outlined, size: 26, color: primaryBlue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '1. INFORMATIONS DE\nL\'ENFANT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    _buildLabel('Nom Complet'),
                    _buildInputField(
                      controller: _nomEnfantController,
                      label: 'Nom de famille de l\'enfant',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Prénoms'),
                    _buildInputField(
                      controller: _prenomEnfantController,
                      label: 'Prénoms de l\'enfant',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Date de Naissance'),
                    _buildInputField(
                      controller: _dateNaissanceController,
                      label: 'mm/dd/yyyy',
                      validator: _requiredValidator,
                      readOnly: true,
                      onTap: _pickDateNaissance,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Sexe'),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Sélectionner',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: const BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'F', child: Text('Féminin')),
                        DropdownMenuItem(value: 'M', child: Text('Masculin')),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Lieu de naissance'),
                    _buildInputField(
                      controller: _villeController,
                      label: 'Lieu de naissance',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Secteur'),
                    _buildInputField(
                      controller: _secteurController,
                      label: 'Secteur ou quartier',
                      validator: _requiredValidator,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSectionCard(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.female_outlined, size: 26, color: primaryBlue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '2. INFORMATIONS DE LA\nMÈRE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    _buildLabel('Nom'),
                    _buildInputField(
                      controller: _nomMereController,
                      label: 'Nom de famille de la mère',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Prénom'),
                    _buildInputField(
                      controller: _prenomMereController,
                      label: 'Prénom(s) de la mère',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Nationalité'),
                    _buildInputField(
                      controller: _nationaliteMereController,
                      label: 'Nationalité',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Profession'),
                    _buildInputField(
                      controller: _professionMereController,
                      label: 'Profession de la mère',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Date de Naissance'),
                    _buildInputField(
                      controller: _dateNaissanceMereController,
                      label: 'mm/dd/yyyy',
                      validator: _requiredValidator,
                      readOnly: true,
                      onTap: _pickDateNaissanceMere,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSectionCard(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.male_outlined, size: 26, color: primaryBlue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '3. INFORMATIONS DU\nPÈRE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    _buildLabel('Nom'),
                    _buildInputField(
                      controller: _nomPereController,
                      label: 'Nom de famille du père',
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Prénom'),
                    _buildInputField(
                      controller: _prenomPereController,
                      label: 'Prénom(s) du père',
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Nationalité'),
                    _buildInputField(
                      controller: _nationalitePereController,
                      label: 'Nationalité',
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Profession'),
                    _buildInputField(
                      controller: _professionPereController,
                      label: 'Profession du père',
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Date de Naissance'),
                    _buildInputField(
                      controller: _dateNaissancePereController,
                      label: 'mm/dd/yyyy',
                      readOnly: true,
                      onTap: _pickDateNaissancePere,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isSubmitting) ...[
                          const Icon(Icons.shield_outlined, size: 20),
                          const SizedBox(width: 8),
                        ],
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _isSubmitting
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Enregistrer l\'acte sur NaissanceChain',
                                  key: ValueKey('label'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _clearAndReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFFBFC7D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text(
                      'Annuler et vider le formulaire',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgentBadge extends StatelessWidget {
  const _AgentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0A1A2F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: const Center(
            child: Icon(Icons.person, color: Color(0xFF0A1A2F), size: 22),
          ),
        ),
      ),
    );
  }
}
