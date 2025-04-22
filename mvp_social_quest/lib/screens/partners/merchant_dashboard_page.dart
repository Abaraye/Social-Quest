// =============================================================
// lib/screens/partners/merchant_dashboard_page.dart – v3.2
// =============================================================
// ✨ Ajout du bouton "Gérer les créneaux" + support onShowCalendar
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantDashboardPage extends StatefulWidget {
  final String? partnerId;
  final String partnerName;
  final Map<DateTime, int> bookingsByDay;
  final double fillRate;
  final double avgRating;
  final double? conversionRate;
  final double? cancelRate;
  final List<Map<String, String>>? allPartners;
  final void Function(String?)? onPartnerSelected;
  final VoidCallback? onShowCalendar; // ✅ Ajout ici

  const MerchantDashboardPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
    required this.bookingsByDay,
    required this.fillRate,
    required this.avgRating,
    this.conversionRate,
    this.cancelRate,
    this.allPartners,
    this.onPartnerSelected,
    this.onShowCalendar,
  });

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  String? _lastPartnerId;

  @override
  void initState() {
    super.initState();
    _loadLastPartner();
  }

  Future<void> _loadLastPartner() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastPartnerId = prefs.getString('last_partner_id');
    });
  }

  Future<void> _saveLastPartner(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_partner_id', id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGlobal = widget.partnerId == null;
    final totalBookings = widget.bookingsByDay.values.fold<int>(
      0,
      (a, b) => a + b,
    );

    final now = DateTime.now();
    final last7 = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );
    final spots = last7.map(
      (d) => FlSpot(
        last7.indexOf(d).toDouble(),
        (widget.bookingsByDay[d] ?? 0).toDouble(),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isGlobal ? 'Toutes mes activités' : widget.partnerName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (!isGlobal)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Modifier activité',
                    onPressed:
                        () => Navigator.pushNamed(
                          context,
                          '/manage/${widget.partnerId}',
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (!isGlobal)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/slots/${widget.partnerId}',
                      ),
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text("Gérer les créneaux"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _kpiCard(
                  context,
                  'Réservations à venir',
                  '$totalBookings',
                  Icons.event_available,
                  onTap: () {
                    if (!isGlobal) {
                      Navigator.pushNamed(
                        context,
                        '/bookings/${widget.partnerId}',
                      );
                    }
                  },
                ),
                _kpiCard(
                  context,
                  'Taux de remplissage',
                  '${(widget.fillRate * 100).round()} %',
                  Icons.query_stats,
                  onTap: () {
                    if (widget.partnerId != null) {
                      Navigator.pushNamed(
                        context,
                        '/fill-rate/${widget.partnerId}',
                      );
                    }
                  },
                ),

                _kpiCard(
                  context,
                  'Note moyenne',
                  widget.avgRating.toStringAsFixed(1),
                  Icons.star_rate,
                  onTap: () {
                    if (!isGlobal) {
                      Navigator.pushNamed(
                        context,
                        '/reviews/${widget.partnerId}',
                      );
                    }
                  },
                ),
                if (widget.conversionRate != null)
                  _kpiCard(
                    context,
                    'Taux de conversion',
                    '${(widget.conversionRate! * 100).round()} %',
                    Icons.leaderboard,
                    onTap: () {},
                  ),
                if (widget.cancelRate != null)
                  _kpiCard(
                    context,
                    'Taux d’annulation',
                    '${(widget.cancelRate! * 100).round()} %',
                    Icons.cancel,
                    onTap: () {},
                  ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              'Réservations – 7 derniers jours',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= last7.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            DateFormat('E').format(last7[i]),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups:
                      spots
                          .map(
                            (s) => BarChartGroupData(
                              x: s.x.toInt(),
                              barRods: [
                                BarChartRodData(
                                  fromY: 0,
                                  toY: s.y,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 130,
            child: Column(
              children: [
                Icon(icon, size: 28, color: Colors.deepPurple),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
