import 'package:flutter/material.dart';

import 'agent_enregistrement_screen.dart';

class AgentRegistrationScreen extends StatelessWidget {
  final String agentName;

  const AgentRegistrationScreen({super.key, required this.agentName});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0A1A2F);
    const border = Color(0xFFD7DFEA);
    const lightBackground = Color(0xFFF4F7FB);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'NaissanceChain',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 20,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
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
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Portail Agent',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF050B17),
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 72,
                height: 4,
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
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
                      height: 4,
                      decoration: const BoxDecoration(
                        color: navy,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.shield_outlined, size: 34, color: navy),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Portail\nd\'enregistrement',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                    height: 1.18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 208,
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF111827),
                                      height: 1.35,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Agent :\n',
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                      ),
                                      TextSpan(
                                        text: agentName,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    '• Matricule: #GC-2024-882',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF6B7280),
                                      fontStyle: FontStyle.italic,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                              border: const Border(
                                left: BorderSide(color: navy, width: 4),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(14, 18, 16, 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.info_outline, color: Color(0xFF42526B), size: 28),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Aucune authentification\nn\'est requise. Ce portail\nouvre simplement la\nsession de travail.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.45,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8E6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit_note, color: Color(0xFF5C6F91), size: 28),
                          ),
                          const SizedBox(width: 18),
                          const Expanded(
                            child: Text(
                              'Prêt à enregistrer un\nacte ?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                height: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 62),
                        child: Text(
                          'Commencez la saisie d\'un\nnouvel acte de naissance\nsécurisé.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF374151),
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgentEnregistrementScreen(agentName: agentName),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF071428),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Commencer\nl\'enregistrement',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 18),
                              Icon(Icons.arrow_forward, size: 30),
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
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120A1A2F),
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
          child: const Center(
            child: Icon(Icons.star, size: 11, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
