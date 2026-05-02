// lib/screens/verification_screen.dart
// Écran pour la vérification des actes de naissance
// Utilisé par les écoles et hôpitaux pour vérifier l'authenticité

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/acte_naissance.dart';
import '../services/blockchain_service.dart';
import '../services/firebase_service.dart';
import '../services/qr_service.dart';

class VerificationScreen extends StatefulWidget {
  final String? initialActeId;

  const VerificationScreen({super.key, this.initialActeId});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  ActeNaissance? _foundActe;
  String? _statusMessage;
  bool _isVerifying = false;
  String? _lastScannedValue;
  bool _isVerificationSuccessful = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialActeId != null) {
      _controller.text = widget.initialActeId!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verifyActe() async {
    final acteId = _controller.text.trim();
    if (acteId.isEmpty) {
      setState(() {
        _statusMessage = 'Veuillez saisir un identifiant d’acte.';
        _foundActe = null;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _statusMessage = null;
      _foundActe = null;
      _isVerificationSuccessful = false;
    });

    final firebaseService = context.read<FirebaseService>();
    final blockchainService = context.read<BlockchainService>();

    final acte = firebaseService.getActe(acteId);
    if (acte == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Aucun acte trouvé pour cet identifiant.';
        _isVerifying = false;
        _isVerificationSuccessful = false;
      });
      return;
    }

    final record = blockchainService.getRecord(acteId);
    final verified = record != null && acte.blockchainHash == record.hash;

    if (!mounted) {
      return;
    }

    setState(() {
      _foundActe = acte;
      _statusMessage = verified
          ? 'Acte vérifié avec succès.'
          : 'Acte trouvé, mais la preuve blockchain ne correspond pas.';
      _isVerificationSuccessful = verified;
      _isVerifying = false;
    });
  }

  Future<void> _handleScan(String? rawValue) async {
    final acteId = rawValue?.trim();
    if (acteId == null || acteId.isEmpty || acteId == _lastScannedValue) {
      return;
    }

    _lastScannedValue = acteId;
    final isValidQr = QRService.isValidQRContent(acteId);

    if (!mounted) {
      return;
    }

      setState(() {
      _statusMessage = isValidQr
        ? 'QR détecté, vérification en cours...'
        : 'QR non valide: le format attendu est GN-YYYY-XXXXXXXX.';
      _foundActe = null;
      _isVerificationSuccessful = false;
    });

    if (!isValidQr) {
      return;
    }

    _controller.text = acteId;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: acteId.length),
    );

    await _verifyActe();
  }

  @override
  Widget build(BuildContext context) {
    const surfaceGrey = Color(0xFFF5F8FB);
    const primaryBlue = Color(0xFF0D1B2A);

    return Scaffold(
      backgroundColor: surfaceGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'NaissanceChain',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: _FlagBadge(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE4EAF1)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'CONTROLE DE VALIDITÉ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7B8DB1),
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vérification\nd\'Authenticité',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B1020),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Placez le QR code de l\'acte de naissance à\nl\'intérieur du cadre pour une validation\ninstantanée.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: Color(0xFF3F4A5A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildScannerPreview(primaryBlue),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) {
                    if (!_isVerifying) _verifyActe();
                  },
                  decoration: InputDecoration(
                    hintText: 'Saisir l\'identifiant manuellement...',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9AA6B6),
                    ),
                    prefixIcon: const Icon(Icons.edit_outlined, color: primaryBlue),
                    suffixIcon: _isVerifying
                        ? const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: primaryBlue,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search, color: primaryBlue),
                            onPressed: _verifyActe,
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFF9AA6B6), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFF9AA6B6), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_statusMessage != null) ...[
                  const Divider(color: Color(0xFFD8DFEA), thickness: 1),
                  const SizedBox(height: 22),
                  if (_isVerificationSuccessful)
                    _buildResultExample(
                      background: const Color(0xFFEAF8E5),
                      accent: const Color(0xFF4CAF50),
                      icon: Icons.verified_user,
                      title: '✅ Acte authentique',
                      description:
                          'Ce document a été certifié conforme par la blockchain NaissanceChain au registre national.\n\nConcerne : ${_foundActe!.nomEnfant} ${_foundActe!.prenomEnfant}',
                      footerLeft: "VÉRIFIÉ PAR L'ÉTAT",
                      footerRight: _foundActe?.blockchainHash != null && _foundActe!.blockchainHash!.length > 8
                          ? '#${_foundActe!.blockchainHash!.substring(0, 4)}...${_foundActe!.blockchainHash!.substring(_foundActe!.blockchainHash!.length - 4)}'.toUpperCase()
                          : (_foundActe?.blockchainHash ?? ''),
                    )
                  else if (_statusMessage == 'Veuillez saisir un identifiant d’acte.' ||
                           _statusMessage == 'QR détecté, vérification en cours...')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD3DBE6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF0D1B2A)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusMessage!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildResultExample(
                      background: const Color(0xFFFDEBEC),
                      accent: const Color(0xFFE53935),
                      icon: Icons.block,
                      title: '❌ Acte non reconnu',
                      description: _statusMessage!,
                      footerLeft: '',
                      footerRight: '',
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
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
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFCE1126), Color(0xFFFCD116), Color(0xFF007A5E)],
            ),
          ),
        ),
      ),
    );
  }
}

extension on _VerificationScreenState {
  Widget _buildScannerPreview(Color primaryBlue) {
    return Container(
      height: 430,
      decoration: BoxDecoration(
        color: const Color(0xFF9A9A9A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFC5CC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180A1A2F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                onDetect: (capture) {
                  final rawValue = capture.barcodes.isNotEmpty
                      ? capture.barcodes.first.rawValue
                      : null;
                  if (rawValue != null) {
                    _handleScan(rawValue);
                  }
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.20),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CornerFrame(color: Colors.black.withValues(alpha: 0.85)),
                  _CornerFrame(color: Colors.black.withValues(alpha: 0.85), mirrored: true),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CornerFrame(color: Colors.black.withValues(alpha: 0.85), bottom: true),
                  _CornerFrame(color: Colors.black.withValues(alpha: 0.85), bottom: true, mirrored: true),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
              child: Text(
                'Visez le QR code pour lancer la vérification automatiquement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultExample({
    required Color background,
    required Color accent,
    required IconData icon,
    required String title,
    required String description,
    required String footerLeft,
    required String footerRight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border(top: BorderSide(color: accent, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      height: 1.08,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: accent.withValues(alpha: 0.88),
                ),
              ),
            ),
            if (footerLeft.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: Color(0xFFD5E6D2)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F766E),
                        shape: BoxShape.rectangle,
                      ),
                      child: const Center(
                        child: Icon(Icons.flag, size: 11, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        footerLeft,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      footerRight,
                      style: TextStyle(
                        fontSize: 11,
                        color: accent.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CornerFrame extends StatelessWidget {
  final Color color;
  final bool mirrored;
  final bool bottom;

  const _CornerFrame({
    required this.color,
    this.mirrored = false,
    this.bottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _CornerFramePainter(color: color, mirrored: mirrored, bottom: bottom),
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  final Color color;
  final bool mirrored;
  final bool bottom;

  _CornerFramePainter({required this.color, required this.mirrored, required this.bottom});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (!bottom) {
      if (!mirrored) {
        path.moveTo(4, size.height);
        path.lineTo(4, 4);
        path.lineTo(size.width, 4);
      } else {
        path.moveTo(size.width - 4, size.height);
        path.lineTo(size.width - 4, 4);
        path.lineTo(0, 4);
      }
    } else {
      if (!mirrored) {
        path.moveTo(4, 0);
        path.lineTo(4, size.height - 4);
        path.lineTo(size.width, size.height - 4);
      } else {
        path.moveTo(size.width - 4, 0);
        path.lineTo(size.width - 4, size.height - 4);
        path.lineTo(0, size.height - 4);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerFramePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.mirrored != mirrored || oldDelegate.bottom != bottom;
  }
}
