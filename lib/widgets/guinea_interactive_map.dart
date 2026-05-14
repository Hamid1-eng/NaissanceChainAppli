import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget de carte interactive professionnelle de la Guinée
/// Utilise une SVG réaliste avec positions fiables des préfectures
class GuineaInteractiveMap extends StatefulWidget {
  final List<String> prefectures;
  final Map<String, int> counts;
  final int maxCount;
  final String Function(double) statusForRate;
  final Color Function(String) statusColor;
  final String Function(double) formatPercent;

  const GuineaInteractiveMap({
    required this.prefectures,
    required this.counts,
    required this.maxCount,
    required this.statusForRate,
    required this.statusColor,
    required this.formatPercent,
    super.key,
  });

  @override
  State<GuineaInteractiveMap> createState() => _GuineaInteractiveMapState();
}

class _GuineaInteractiveMapState extends State<GuineaInteractiveMap> {
  /// Positions des préfectures (% du conteneur, adaptées à la SVG)
  final Map<String, Offset> _prefecturePositions = {
    'Conakry': const Offset(0.30, 0.50), // Sud-ouest
    'Kindia': const Offset(0.32, 0.42), // Ouest-centre
    'Labé': const Offset(0.50, 0.25), // Nord
    'Mamou': const Offset(0.48, 0.45), // Centre
    'Kankan': const Offset(0.65, 0.42), // Est
    'N\'Zérékoré': const Offset(0.52, 0.65), // Sud-est
    'Boké': const Offset(0.35, 0.28), // Nord-ouest
    'Faranah': const Offset(0.58, 0.58), // Centre-est
  };

  void _showPrefectureDetails(String prefecture, Offset position) {
    final count = widget.counts[prefecture] ?? 0;
    final rate = widget.maxCount == 0 ? 0.0 : (count / widget.maxCount) * 100;
    final status = widget.statusForRate(rate);
    final color = count == 0
        ? const Color(0xFFCBD5E1)
        : widget.statusColor(status);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PrefectureDetailsDialog(
        prefecture: prefecture,
        count: count,
        rate: rate,
        status: status,
        color: color,
        formatPercent: widget.formatPercent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const Text(
                  'Carte de couverture nationale',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A1A2F),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Données actualisées en temps réel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),

                // Cartouche institutionnel
                _InstitutionalHeader(),
                const SizedBox(height: 12),

                // Instructions
                const Text(
                  '👆 Cliquez sur les points pour voir les détails',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),

                // Carte responsive sans overflow
                Container(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD6DEE8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // SVG de Guinée
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                'assets/maps/guinea.svg',
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) => Container(
                                  color: const Color(0xFFF8FAFC),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Points cliquables préfectures
                            ..._buildPrefecturePoints(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Légende code couleur
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _LegendChip(
                      label: 'Bon (≥70%)',
                      color: const Color(0xFF16A34A),
                    ),
                    _LegendChip(
                      label: 'Moyen (35-69%)',
                      color: const Color(0xFFF59E0B),
                    ),
                    _LegendChip(
                      label: 'Faible (<35%)',
                      color: const Color(0xFFDC2626),
                    ),
                    _LegendChip(
                      label: 'Sans données',
                      color: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Représentation professionnelle reliée aux données Firestore',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrefecturePoints() {
    return widget.prefectures.map((prefecture) {
      final position =
          _prefecturePositions[prefecture] ?? const Offset(0.5, 0.5);
      final count = widget.counts[prefecture] ?? 0;
      final rate = widget.maxCount == 0 ? 0.0 : (count / widget.maxCount) * 100;
      final status = widget.statusForRate(rate);
      final color = count == 0
          ? const Color(0xFFCBD5E1)
          : widget.statusColor(status);

      return Positioned(
        left: position.dx * 100,
        top: position.dy * 100,
        child: GestureDetector(
          onTap: () => _showPrefectureDetails(prefecture, position),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: '$prefecture\n$count acte${count != 1 ? 's' : ''}',
              child: Transform.translate(
                offset: const Offset(-16, -16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.95),
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Dialog détails d'une préfecture
class _PrefectureDetailsDialog extends StatelessWidget {
  final String prefecture;
  final int count;
  final double rate;
  final String status;
  final Color color;
  final String Function(double) formatPercent;

  const _PrefectureDetailsDialog({
    required this.prefecture,
    required this.count,
    required this.rate,
    required this.status,
    required this.color,
    required this.formatPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isNoData = count == 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Préfecture',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        prefecture,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A1A2F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Actes enregistrés',
                    value: '$count',
                    subtext: count == 1 ? 'acte' : 'actes',
                    icon: Icons.how_to_reg_outlined,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    label: 'Taux de couverture',
                    value: isNoData ? 'N/A' : formatPercent(rate),
                    subtext: isNoData ? 'aucune donnée' : 'estimé',
                    icon: Icons.trending_up_outlined,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statut
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        isNoData ? 'Neutre' : status,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Fermer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Détails de $prefecture'),
                          backgroundColor: color,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Voir plus',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Item statistique
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Légende
class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête institutionnel
class _InstitutionalHeader extends StatelessWidget {
  const _InstitutionalHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A2F).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0A1A2F).withValues(alpha: 0.10),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 16,
            color: Color(0xFF0A1A2F),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ministère de l\'Administration du Territoire',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1A2F),
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'République de Guinée',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
