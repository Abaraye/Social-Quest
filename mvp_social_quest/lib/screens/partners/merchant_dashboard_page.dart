import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mvp_social_quest/widgets/partners/dashboard/kpi_card.dart';
import 'package:mvp_social_quest/widgets/partners/manage/manage_partner_slots_section.dart';

/// MerchantDashboardPage displays summary KPIs above the calendar widget and a bookings chart for a partner.
/// The KPI cards are presented horizontally below the title and above the calendar.
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

  const MerchantDashboardPage({
    Key? key,
    required this.partnerId,
    required this.partnerName,
    required this.bookingsByDay,
    required this.fillRate,
    required this.avgRating,
    this.conversionRate,
    this.cancelRate,
    this.allPartners,
    this.onPartnerSelected,
  }) : super(key: key);

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGlobal = widget.partnerId == null;

    // Total upcoming bookings
    final totalBookings = widget.bookingsByDay.values.fold<int>(
      0,
      (a, b) => a + b,
    );

    // Prepare 7-day range for bookings chart
    final now = DateTime.now();
    final last7 = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );
    final spots =
        last7
            .map(
              (d) => FlSpot(
                last7.indexOf(d).toDouble(),
                (widget.bookingsByDay[d] ?? 0).toDouble(),
              ),
            )
            .toList();

    // KPI definitions
    final kpis = [
      {
        'label': 'Réservations à venir',
        'value': '$totalBookings',
        'icon': Icons.event_available,
        'route': '/bookings/${widget.partnerId}',
      },
      {
        'label': 'Taux de remplissage',
        'value': '${(widget.fillRate * 100).round()} %',
        'icon': Icons.query_stats,
        'route': '/fill-rate/${widget.partnerId}',
      },
      {
        'label': 'Note moyenne',
        'value': widget.avgRating.toStringAsFixed(1),
        'icon': Icons.star_rate,
        'route': '/reviews/${widget.partnerId}',
      },
      if (widget.conversionRate != null)
        {
          'label': 'Taux de conversion',
          'value': '${(widget.conversionRate! * 100).round()} %',
          'icon': Icons.swap_vert,
          'route': '/conversion/${widget.partnerId}',
        },
      if (widget.cancelRate != null)
        {
          'label': 'Taux d\'annulation',
          'value': '${(widget.cancelRate! * 100).round()} %',
          'icon': Icons.cancel,
          'route': '/cancellations/${widget.partnerId}',
        },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.partnerName, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          // KPI cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  kpis.map((kpi) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: KpiCard(
                        icon: kpi['icon'] as IconData,
                        value: kpi['value'] as String,
                        label: kpi['label'] as String,
                        onTap: () {
                          if (!isGlobal && kpi['route'] != null) {
                            Navigator.pushNamed(
                              context,
                              kpi['route'] as String,
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Calendar / slots management
          if (widget.partnerId != null)
            ManagePartnerSlotsSection(partnerId: widget.partnerId!),

          const SizedBox(height: 32),

          // Bookings chart
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
                        if (i < 0 || i >= last7.length)
                          return const SizedBox.shrink();
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
                    spots.map((spot) {
                      return BarChartGroupData(
                        x: spot.x.toInt(),
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: spot.y,
                            width: 14,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
