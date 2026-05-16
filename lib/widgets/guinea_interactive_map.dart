import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;

class _PrefectureMarkerSpec {
  final String displayName;
  final Offset position;
  final List<String> aliases;

  const _PrefectureMarkerSpec({
    required this.displayName,
    required this.position,
    this.aliases = const [],
  });
}

/// Carte interactive de la Guinée basée sur l'image réelle fournie.
/// Les marqueurs sont positionnés manuellement au-dessus de l'image.
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
  final List<_PrefectureMarkerSpec> _markers = const [
    _PrefectureMarkerSpec(displayName: 'Boké', position: Offset(0.11, 0.30)),
    _PrefectureMarkerSpec(displayName: 'Labé', position: Offset(0.47, 0.23)),
    _PrefectureMarkerSpec(displayName: 'Kindia', position: Offset(0.26, 0.47)),
    _PrefectureMarkerSpec(displayName: 'Mamou', position: Offset(0.49, 0.43)),
    _PrefectureMarkerSpec(displayName: 'Kankan', position: Offset(0.74, 0.45)),
    _PrefectureMarkerSpec(displayName: 'Faranah', position: Offset(0.61, 0.63)),
    _PrefectureMarkerSpec(displayName: 'Conakry', position: Offset(0.13, 0.56)),
    _PrefectureMarkerSpec(
      displayName: 'Nzérékoré',
      position: Offset(0.84, 0.85),
      aliases: ['N\'Zérékoré'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAndColorizeSvg();
  }

  @override
  void didUpdateWidget(covariant GuineaInteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.counts != widget.counts) {
      _loadAndColorizeSvg();
    }
  }

  String? _coloredSvg;

  Future<void> _loadAndColorizeSvg() async {
    try {
      final raw = await rootBundle.loadString('assets/maps/guinea_regions.svg');
      final doc = xml.XmlDocument.parse(raw);

      String normalizeLocal(String v) => _normalizeKey(v);

      final Map<String, String> colorByName = {};
      for (final marker in _markers) {
        final count = _countForMarker(marker);
        final rate = widget.maxCount == 0
            ? 0.0
            : (count / widget.maxCount) * 100;
        final color = _markerColor(count, rate);
        final argb = color.toARGB32();
        final hex =
            '#${((argb >> 16) & 0xFF).toRadixString(16).padLeft(2, '0')}${((argb >> 8) & 0xFF).toRadixString(16).padLeft(2, '0')}${(argb & 0xFF).toRadixString(16).padLeft(2, '0')}';
        colorByName[normalizeLocal(marker.displayName)] = hex;
        for (final a in marker.aliases) {
          colorByName[normalizeLocal(a)] = hex;
        }
      }

      for (final node in doc.findAllElements('path')) {
        final titleAttr = node.getAttribute('title');
        final idAttr = node.getAttribute('id');

        String? key;
        if (titleAttr != null &&
            colorByName.containsKey(normalizeLocal(titleAttr))) {
          key = normalizeLocal(titleAttr);
        } else if (idAttr != null) {
          final normalizedId = idAttr.toLowerCase();
          for (final marker in _markers) {
            final idGuess = marker.displayName.toLowerCase();
            if (normalizedId.contains(idGuess.split(' ').first)) {
              key = normalizeLocal(marker.displayName);
              break;
            }
          }
        }

        if (key != null && colorByName.containsKey(key)) {
          node.setAttribute('fill', colorByName[key]!);
        }
      }

      setState(() {
        _coloredSvg = doc.toXmlString(pretty: false);
      });
    } catch (e) {
      setState(() {
        _coloredSvg = null;
      });
    }
  }

  String _normalizeKey(String value) =>
      value.toLowerCase().replaceAll("'", '').replaceAll('’', '').trim();

  _PrefectureMarkerSpec? _markerForPrefecture(String prefecture) {
    final normalized = _normalizeKey(prefecture);

    for (final marker in _markers) {
      final names = <String>[marker.displayName, ...marker.aliases];
      for (final name in names) {
        if (_normalizeKey(name) == normalized) {
          return marker;
        }
      }
    }

    return null;
  }

  int _countForMarker(_PrefectureMarkerSpec marker) {
    final keys = <String>[marker.displayName, ...marker.aliases];
    for (final key in keys) {
      final count = widget.counts[key];
      if (count != null) {
        return count;
      }
    }

    final normalizedTarget = _normalizeKey(marker.displayName);
    for (final entry in widget.counts.entries) {
      if (_normalizeKey(entry.key) == normalizedTarget) {
        return entry.value;
      }
    }

    return 0;
  }

  Color _markerColor(int count, double rate) {
    if (count == 0) {
      return const Color(0xFFCBD5E1);
    }
    return widget.statusColor(widget.statusForRate(rate));
  }

  void _showPrefectureDetails(String prefecture) {
    final marker = _markerForPrefecture(prefecture);
    final count = marker == null
        ? (widget.counts[prefecture] ?? 0)
        : _countForMarker(marker);
    final rate = widget.maxCount == 0 ? 0.0 : (count / widget.maxCount) * 100;
    final status = widget.statusForRate(rate);
    final color = _markerColor(count, rate);

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
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const _InstitutionalHeader(),
            const SizedBox(height: 12),
            const Text(
              'Cliquez sur les points pour voir les détails',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AspectRatio(
                aspectRatio: 1.4,
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
                        _coloredSvg != null
                            ? SvgPicture.string(
                                _coloredSvg!,
                                fit: BoxFit.fill,
                                semanticsLabel: 'Carte de la Guinée',
                                placeholderBuilder: (context) {
                                  return Container(
                                    color: const Color(0xFFF8FAFC),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : SvgPicture.asset(
                                'assets/maps/guinea_regions.svg',
                                fit: BoxFit.fill,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFE0E7FF),
                                  BlendMode.lighten,
                                ),
                                semanticsLabel: 'Carte de la Guinée',
                                placeholderBuilder: (context) {
                                  return Container(
                                    color: const Color(0xFFF8FAFC),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: _buildMarkers(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: const [
                _LegendChip(label: 'Bon (≥70%)', color: Color(0xFF16A34A)),
                _LegendChip(label: 'Moyen (35-69%)', color: Color(0xFFF59E0B)),
                _LegendChip(label: 'Faible (<35%)', color: Color(0xFFDC2626)),
                _LegendChip(label: 'Sans données', color: Color(0xFFCBD5E1)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Image réelle de la Guinée reliée aux données Firestore',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMarkers(double width, double height) {
    return _markers.map((marker) {
      final count = _countForMarker(marker);
      final rate = widget.maxCount == 0 ? 0.0 : (count / widget.maxCount) * 100;
      final color = _markerColor(count, rate);

      final left = ((marker.position.dx * width) - 17)
          .clamp(6.0, width - 40.0)
          .toDouble();
      final top = ((marker.position.dy * height) - 34)
          .clamp(6.0, height - 40.0)
          .toDouble();

      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: () => _showPrefectureDetails(marker.displayName),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message:
                  '${marker.displayName}\n$count acte${count != 1 ? 's' : ''}',
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.location_on, size: 34, color: color),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      onPressed: () => Navigator.pop(context),
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
      ),
    );
  }
}

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
