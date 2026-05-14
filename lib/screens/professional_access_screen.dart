import 'package:flutter/material.dart';

import 'verification_screen.dart';
import 'admin_access_screen.dart';

class ProfessionalAccessScreen extends StatefulWidget {
  const ProfessionalAccessScreen({super.key});

  @override
  State<ProfessionalAccessScreen> createState() =>
      _ProfessionalAccessScreenState();
}

class _ProfessionalAccessScreenState extends State<ProfessionalAccessScreen> {
  final TextEditingController _identityController = TextEditingController();
  String _selectedRole = 'agent';

  @override
  void dispose() {
    _identityController.dispose();
    super.dispose();
  }

  void _continue() {
    // If admin selected, go directly to admin access screen (demo code entry there)
    if (_selectedRole == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminAccessScreen()),
      );
      return;
    }

    final identity = _identityController.text.trim();
    if (identity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un code ou un nom d\'institution.'),
        ),
      );
      return;
    }

    if (_selectedRole == 'agent') {
      Navigator.pushNamed(context, '/agent-info');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('NaissanceChain'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(padding: const EdgeInsets.all(8.0), child: _GuineanFlag()),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              const Text(
                'Connexion\nProfessionnelle',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A1A2F),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Sous-titre
              const Text(
                'Sélectionnez votre rôle et identifiez votre institution.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              // Carte Agent d'enregistrement
              _RoleCard(
                icon: Icons.group_outlined,
                title: 'Agent d\'enregistrement',
                subtitle: 'Services d\'état civil',
                isSelected: _selectedRole == 'agent',
                onTap: () {
                  setState(() => _selectedRole = 'agent');
                },
              ),
              const SizedBox(height: 12),
              // Carte École / Hôpital
              _RoleCard(
                icon: Icons.apartment_outlined,
                title: 'École / Hôpital',
                subtitle: 'Établissements accrédités',
                isSelected: _selectedRole == 'verification',
                onTap: () {
                  setState(() => _selectedRole = 'verification');
                },
              ),
              const SizedBox(height: 12),
              // Carte Administration nationale
              _RoleCard(
                icon: Icons.account_balance,
                title: 'Administration nationale',
                subtitle: 'Ministère de l\'Etat civil',
                isSelected: _selectedRole == 'admin',
                onTap: () {
                  setState(() => _selectedRole = 'admin');
                },
              ),
              const SizedBox(height: 24),
              // Label du champ
              const Text(
                'CODE OU NOM DE L\'INSTITUTION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              // Champ d'entrée
              TextField(
                controller: _identityController,
                decoration: InputDecoration(
                  hintText: 'Ex: MATD-224-CONAKRY',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAEB9C6),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.apartment_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF0A1A2F),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bouton Continuer
              ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1A2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continuer →',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 24),
              // Note de sécurité
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: Color(0xFF0A1A2F),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cet accès est strictement réservé au personnel autorisé. Chaque connexion est enregistrée sur la blockchain pour garantir la traçabilité et l\'intégrité des données d\'état civil.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Footer ministère
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFD1D5DB),
                      size: 40,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Ministère de l\'Administration du\nTerritoire et de la Décentralisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A1A2F),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'RÉPUBLIQUE DE GUINÉE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0A1A2F)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0A1A2F)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF0A1A2F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A1A2F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isSelected
                    ? const Color(0xFF0A1A2F)
                    : const Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuineanFlag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 24,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Rouge
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 12,
              child: Container(color: const Color(0xFFCE1126)),
            ),
            // Jaune
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              width: 12,
              child: Container(color: const Color(0xFFFCD116)),
            ),
            // Vert
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 12,
              child: Container(color: const Color(0xFF007A5E)),
            ),
          ],
        ),
      ),
    );
  }
}
