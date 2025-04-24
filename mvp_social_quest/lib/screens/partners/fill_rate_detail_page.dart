// lib/screens/partners/fill_rate_detail_page.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/widgets/partners/slots/slots_calendar_page.dart';
import 'package:mvp_social_quest/widgets/partners/stats_overview.dart';
import 'package:mvp_social_quest/services/firestore/slot_service.dart';
import 'package:mvp_social_quest/services/firestore/stats_service.dart';

class FillRateDetailPage extends StatefulWidget {
  final String partnerId;
  const FillRateDetailPage({Key? key, required this.partnerId})
    : super(key: key);

  @override
  State<FillRateDetailPage> createState() => _FillRateDetailPageState();
}

class _FillRateDetailPageState extends State<FillRateDetailPage> {
  double? fillRate;
  int? totalSlots;
  int? totalBookings;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final allSlots = await SlotService.getExpandedSlots(widget.partnerId);
    final upcoming = allSlots.where((s) => s.startTime.isAfter(DateTime.now()));

    final stats = await StatsService.getPartnerStats(widget.partnerId);

    setState(() {
      totalSlots = upcoming.length;
      totalBookings = stats.bookingsByDay.values.fold<int>(
        0,
        (sum, v) => sum + (v ?? 0),
      );
      fillRate = stats.fillRate;
    });
  }

  void _openSlotsCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SlotsCalendar(
              partnerId: widget.partnerId,
              mode: SlotsCalendarMode.view,
            ),
      ),
    );
  }

  void _openBookingsPage() {
    Navigator.pushNamed(context, '/bookings/${widget.partnerId}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Prépare la liste de StatTile
    final statsList = <StatTile>[
      StatTile(
        label: 'Créneaux à venir',
        value: totalSlots?.toString() ?? '…',
        onTap: _openSlotsCalendar,
      ),
      StatTile(
        label: 'Réservations totales',
        value: totalBookings?.toString() ?? '…',
        onTap: _openBookingsPage,
      ),
      StatTile(
        label: 'Taux de remplissage',
        value: fillRate != null ? '${(fillRate! * 100).round()} %' : '…',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taux de remplissage'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '📈 Statistiques détaillées',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            StatsOverview(stats: statsList),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '📅 Calendrier des créneaux',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SlotsCalendar(
              partnerId: widget.partnerId,
              mode: SlotsCalendarMode.view,
            ),
          ],
        ),
      ),
    );
  }
}
