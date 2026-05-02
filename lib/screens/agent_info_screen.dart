import 'package:flutter/material.dart';

import 'agent_registration_screen.dart';

class AgentInfoScreen extends StatefulWidget {
  const AgentInfoScreen({super.key});

  @override
  State<AgentInfoScreen> createState() => _AgentInfoScreenState();
}

class _AgentInfoScreenState extends State<AgentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  static const Color _warningYellow = Color(0xFFF2C94C);
  static const Color _navy = Color(0xFF0A1A2F);
  static const Color _border = Color(0xFFD5DDE8);

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startRegistration() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final agentName = _nameController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentRegistrationScreen(agentName: agentName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'NaissanceChain',
          style: TextStyle(
            color: _navy,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: _EmblemBadge(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE4EAF1)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 84),
                const Text(
                  'Identification agent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF050B17),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Cette étape sert uniquement à identifier\nl’agent avant l’enregistrement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.45,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120A1A2F),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _navy, width: 4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.badge_outlined, size: 34, color: _navy),
                                  SizedBox(width: 14),
                                  Text(
                                    'Entrée agent',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: _navy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const Divider(color: Color(0xFFE6EBF2), height: 1),
                              const SizedBox(height: 34),
                              const Text(
                                'NOM DE L\'AGENT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _navy,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF111827),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Saisir votre nom complet',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7C8698),
                                    fontSize: 18,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 22,
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: _border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: _border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: _navy,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: _warningYellow,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: _warningYellow,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Le nom de l’agent est requis.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'CODE / POSTE (OPTIONNEL)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _navy,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _codeController,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF111827),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Référence du poste ou code ID',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7C8698),
                                    fontSize: 18,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 22,
                                  ),
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: _border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: _border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: _navy,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 34),
                              SizedBox(
                                height: 74,
                                child: ElevatedButton(
                                  onPressed: _startRegistration,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF020A19),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Commencer l’enregistrement',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Icon(Icons.arrow_forward, size: 28),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.verified_user_outlined, size: 22, color: Color(0xFFB3BCCB)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'CONNEXION SÉCURISÉE VIA NAISSANCECHAIN\nREGISTRY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB3BCCB),
                            letterSpacing: 1.0,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
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

class _EmblemBadge extends StatelessWidget {
  const _EmblemBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFFF2C94C), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFFE7B33D),
                  Color(0xFFB88918),
                ],
              ),
              border: Border.all(color: const Color(0xFF1E293B), width: 1),
            ),
          ),
          const Icon(
            Icons.shield,
            size: 18,
            color: Color(0xFF0A1A2F),
          ),
          Positioned(
            bottom: 7,
            child: Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF007A5E),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
