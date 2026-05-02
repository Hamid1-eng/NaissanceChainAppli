import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/acte_naissance.dart';
import '../services/firebase_service.dart';
import '../services/qr_service.dart';

class FamilleScreen extends StatefulWidget {
  final String? initialActeId;

  const FamilleScreen({super.key, this.initialActeId});

  @override
  State<FamilleScreen> createState() => _FamilleScreenState();
}

class _FamilleScreenState extends State<FamilleScreen> {
  final TextEditingController _idQueryController = TextEditingController();

  ActeNaissance? _selectedActe;

  @override
  void initState() {
    super.initState();
    if (widget.initialActeId != null && widget.initialActeId!.isNotEmpty) {
      _idQueryController.text = widget.initialActeId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _consultExtract();
      });
    }
  }

  @override
  void dispose() {
    _idQueryController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scanQrCode() {
    _showMessage('Scanneur QR à connecter sur l’écran famille.');
  }

  void _consultExtract() {
    final query = _idQueryController.text.trim();
    if (query.isEmpty) {
      _showMessage('Veuillez saisir l\'identifiant de l\'acte.');
      return;
    }
    final firebaseService = context.read<FirebaseService>();
    final acte = firebaseService.getActe(query);
    if (acte == null) {
      _showMessage('Aucun acte trouvé pour cet identifiant.');
      return;
    }
    setState(() {
      _selectedActe = acte;
    });
  }

  ActeNaissance? get _activeActe => _selectedActe;

  Future<void> _downloadExtract(BuildContext context, ActeNaissance? acte) async {
    if (acte == null) {
      _showMessage('Aucun acte disponible à télécharger.');
      return;
    }

    final pdfBytes = await _buildPdf(acte);
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'extrait_${acte.id}.pdf',
    );
  }

  Future<void> _shareExtract(ActeNaissance? acte) async {
    if (acte == null) {
      _showMessage('Aucun acte disponible à partager.');
      return;
    }

    final pdfBytes = await _buildPdf(acte);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'extrait_${acte.id}.pdf',
    );
  }

  Future<Uint8List> _buildPdf(ActeNaissance acte) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NaissanceChain',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Extrait de naissance',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 18),
                _pdfRow('ID', acte.id),
                _pdfRow('Nom de l\'enfant', acte.nomEnfant),
                _pdfRow('Prénom de l\'enfant', acte.prenomEnfant),
                _pdfRow(
                  'Date de naissance',
                  '${acte.dateNaissance.day.toString().padLeft(2, '0')}/${acte.dateNaissance.month.toString().padLeft(2, '0')}/${acte.dateNaissance.year}',
                ),
                _pdfRow('Lieu de naissance', acte.lieuNaissance),
                _pdfRow('Nom de la mère', acte.nomMere),
                _pdfRow('Prénom de la mère', acte.prenomMere),
                _pdfRow('Profession de la mère', acte.professionMere ?? '-'),
                _pdfRow('Nom du père', acte.nomPere ?? '-'),
                _pdfRow('Prénom du père', acte.prenomPere ?? '-'),
                _pdfRow('Profession du père', acte.professionPere ?? '-'),
                _pdfRow('Ville', acte.ville ?? '-'),
                _pdfRow('Secteur', acte.secteur ?? '-'),
                _pdfRow(
                  'Statut blockchain',
                  acte.isBlockchainVerified ? 'Vérifié' : 'En cours',
                ),
                pw.SizedBox(height: 18),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: QRService.generateQRContent(acte.id),
                    width: 140,
                    height: 140,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'QR code de vérification',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return document.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label :',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }



  String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const deepNavy = Color(0xFF0D1B2A);
    const surfaceGrey = Color(0xFFF5F8FB);
    final activeActe = _activeActe;

    return Scaffold(
      backgroundColor: surfaceGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: deepNavy),
        title: const Text(
          'NaissanceChain',
          style: TextStyle(
            color: deepNavy,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
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
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Espace Famille',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B1020),
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Consultez ou téléchargez un extrait d\'acte de naissance.',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.45,
                  color: Color(0xFF3F4A5A),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'IDENTIFIANT DE L\'ACTE (GN-AAAA-XXXXXXXX)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3F4A5A),
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _idQueryController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Entrez l'identifiant",
                  hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF7B8796)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(color: Color(0xFFC7CFDA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(color: Color(0xFFC7CFDA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide: const BorderSide(color: deepNavy, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _consultExtract,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF020A19),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text(
                    'Consulter l’extrait',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (activeActe != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'APERÇU RÉCENT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3F4A5A),
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 12),
                _FamilyPreviewCard(
                  activeActe: activeActe,
                  displayDate: _displayDate,
                  onDownload: () => _downloadExtract(context, activeActe),
                  onShare: () => _shareExtract(activeActe),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFC9D1DC), thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFC9D1DC), thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: _scanQrCode,
                  icon: const Icon(Icons.qr_code_2, color: Color(0xFF0D1B2A), size: 26),
                  label: const Text(
                    "Scanner le QR code de l'acte",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1F2937), width: 1.1),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyPreviewCard extends StatelessWidget {
  final ActeNaissance activeActe;
  final String Function(DateTime date) displayDate;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const _FamilyPreviewCard({
    required this.activeActe,
    required this.displayDate,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final sampleName = '${activeActe.nomEnfant} ${activeActe.prenomEnfant}';
    final sampleDate = displayDate(activeActe.dateNaissance);
    final samplePlace = activeActe.lieuNaissance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: const Border(
          top: BorderSide(color: Color(0xFF0D1B2A), width: 2),
          left: BorderSide(color: Color(0xFFD3DBE6)),
          right: BorderSide(color: Color(0xFFD3DBE6)),
          bottom: BorderSide(color: Color(0xFFD3DBE6)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Extrait d'acte de naissance\n#${activeActe.id}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B2A),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SÉCURISÉ PAR BLOCKCHAIN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2CA02C),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 78,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  border: Border.all(color: const Color(0xFFE4E7EB)),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 32, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE5EAF1), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NOM COMPLET',
                  style: TextStyle(fontSize: 16, color: Color(0xFF3F4A5A)),
                ),
              ),
              Expanded(
                child: Text(
                  sampleName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'DATE DE NAISSANCE',
                  style: TextStyle(fontSize: 16, color: Color(0xFF3F4A5A)),
                ),
              ),
              Expanded(
                child: Text(
                  sampleDate,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'LIEU',
                  style: TextStyle(fontSize: 16, color: Color(0xFF3F4A5A)),
                ),
              ),
              Expanded(
                child: Text(
                  samplePlace,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: Container(
                    color: const Color(0xFFDEE2E6),
                    child: InkWell(
                      onTap: onDownload,
                      child: const Center(
                        child: Text(
                          'Télécharger (PDF)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: Container(
                    color: const Color(0xFFDDEFE8),
                    child: InkWell(
                      onTap: onShare,
                      child: const Center(
                        child: Text(
                          'Partager',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'DOCUMENT CERTIFIÉ CONFORME PAR LE MATD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3F4A5A),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
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
          BoxShadow(color: Color(0x0C0A1A2F), blurRadius: 6, offset: Offset(0, 2)),
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
