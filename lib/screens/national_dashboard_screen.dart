import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';
import '../widgets/guinea_interactive_map.dart';

class NationalDashboardScreen extends StatefulWidget {
  const NationalDashboardScreen({super.key});

  @override
  State<NationalDashboardScreen> createState() =>
      _NationalDashboardScreenState();
}

class _NationalDashboardScreenState extends State<NationalDashboardScreen> {
  static const List<String> _prefectures = [
    'Conakry',
    'Kindia',
    'Labé',
    'Kankan',
    'N’Zérékoré',
    'Boké',
    'Mamou',
    'Faranah',
  ];

  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = context.read<FirebaseService>().getActesCountByPrefecture();
  }

  void _reload() {
    setState(() {
      _statsFuture = context
          .read<FirebaseService>()
          .getActesCountByPrefecture();
    });
  }

  String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';

  String _statusForRate(double rate) {
    if (rate >= 70) return 'Bon';
    if (rate >= 35) return 'Moyen';
    return 'Faible';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Bon':
        return const Color(0xFF16A34A);
      case 'Moyen':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFDC2626);
    }
  }

  int _priorityForStatus(String status) {
    switch (status) {
      case 'Faible':
        return 0;
      case 'Moyen':
        return 1;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Tableau de bord national'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0A1A2F),
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, int>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final counts = snapshot.data ?? {};
            final values = _prefectures.map((p) => counts[p] ?? 0).toList();
            final total = values.fold<int>(0, (sum, value) => sum + value);
            final maxCount = values.isEmpty
                ? 0
                : values.reduce((a, b) => a > b ? a : b);
            final minCount = values.isEmpty
                ? 0
                : values.reduce((a, b) => a < b ? a : b);
            final topPrefecture = maxCount == 0
                ? 'Aucune donnée'
                : _prefectures[values.indexOf(maxCount)];
            final lowPrefecture = maxCount == 0
                ? 'Aucune donnée'
                : _prefectures[values.indexOf(minCount)];
            final nationalRate = maxCount == 0
                ? 0.0
                : (values.fold<double>(
                        0,
                        (sum, value) => sum + ((value / maxCount) * 100),
                      ) /
                      _prefectures.length);

            final sortedPrefectures =
                _prefectures.map((prefecture) {
                  final count = counts[prefecture] ?? 0;
                  final rate = maxCount == 0 ? 0.0 : (count / maxCount) * 100;
                  final status = _statusForRate(rate);
                  return _PrefectureRowData(
                    prefecture: prefecture,
                    count: count,
                    rate: rate,
                    status: status,
                    priority: _priorityForStatus(status),
                  );
                }).toList()..sort(
                  (a, b) => a.priority != b.priority
                      ? a.priority.compareTo(b.priority)
                      : a.count.compareTo(b.count),
                );

            final priorityZone = sortedPrefectures.isEmpty
                ? null
                : sortedPrefectures.firstWhere(
                    (row) => row.status == 'Faible',
                    orElse: () => sortedPrefectures.first,
                  );

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _InstitutionalBanner(
                    total: total,
                    nationalRate: _formatPercent(nationalRate),
                    priorityLabel: priorityZone == null
                        ? 'Aucune donnée'
                        : '${priorityZone.prefecture} - ${priorityZone.status}',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: 'Total national',
                          value: '$total',
                          subtitle: 'actes enregistrés',
                          icon: Icons.how_to_reg,
                          color: const Color(0xFF0A1A2F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          title: 'Taux national estimé',
                          value: _formatPercent(nationalRate),
                          subtitle: 'indice de couverture',
                          icon: Icons.trending_up,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: 'Préfecture la plus couverte',
                          value: topPrefecture,
                          subtitle: maxCount == 0
                              ? 'aucune donnée'
                              : '$maxCount actes',
                          icon: Icons.emoji_events_outlined,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          title: 'Préfecture la moins couverte',
                          value: lowPrefecture,
                          subtitle: minCount == 0
                              ? 'aucune donnée'
                              : '$minCount actes',
                          icon: Icons.flag_outlined,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Tableau par préfecture',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          const Color(0xFFF1F5F9),
                        ),
                        sortColumnIndex: 3,
                        sortAscending: true,
                        columns: const [
                          DataColumn(label: Text('Préfecture')),
                          DataColumn(label: Text('Nombre d’actes')),
                          DataColumn(label: Text('Taux')),
                          DataColumn(label: Text('Statut')),
                        ],
                        rows: sortedPrefectures.map((row) {
                          final color = _statusColor(row.status);

                          return DataRow(
                            cells: [
                              DataCell(Text(row.prefecture)),
                              DataCell(Text('${row.count}')),
                              DataCell(Text(_formatPercent(row.rate))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    row.status,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Carte de couverture nationale',
                    child: GuineaInteractiveMap(
                      prefectures: _prefectures,
                      counts: counts,
                      maxCount: maxCount,
                      statusForRate: _statusForRate,
                      statusColor: _statusColor,
                      formatPercent: _formatPercent,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Tableau de bord national',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0A1A2F),
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Couverture de l’enregistrement des naissances',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Données agrégées – démonstration',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0A1A2F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _InstitutionalBanner extends StatelessWidget {
  final int total;
  final String nationalRate;
  final String priorityLabel;

  const _InstitutionalBanner({
    required this.total,
    required this.nationalRate,
    required this.priorityLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1A2F), Color(0xFF12365A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilotage national',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBFD5F3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total actes consolidés',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Taux estimé: $nationalRate',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Priorité',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBFD5F3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priorityLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A1A2F),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PrefectureRowData {
  final String prefecture;
  final int count;
  final double rate;
  final String status;
  final int priority;

  const _PrefectureRowData({
    required this.prefecture,
    required this.count,
    required this.rate,
    required this.status,
    required this.priority,
  });
}
