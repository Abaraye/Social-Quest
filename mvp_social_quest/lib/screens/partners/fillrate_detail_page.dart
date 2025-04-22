import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/firestore/slot_service.dart';
import '../../services/firestore/stats_service.dart';
import '../../widgets/partners/dashboard/mini_calendar.dart';

class FillRateDetailPage extends StatefulWidget {
  final String partnerId;

  const FillRateDetailPage({super.key, required this.partnerId});

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
    final slots = await SlotService.getPartnerSlots(widget.partnerId);
    final bookingsSnap = await StatsService.getPartnerStats(widget.partnerId);

    final upcomingSlots =
        slots.where((s) {
          final start = (s['startTime'] as Timestamp).toDate();
          return start.isAfter(DateTime.now());
        }).toList();

    setState(() {
      totalSlots = upcomingSlots.length;
      fillRate = bookingsSnap.fillRate;
      totalBookings = bookingsSnap.bookingsByDay.values.fold<int>(
        0,
        (a, b) => a + (b ?? 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taux de remplissage'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('📈 Statistiques détaillées', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _statTile(
            context,
            'Nombre total de créneaux à venir',
            totalSlots?.toString() ?? '…',
            onTap:
                () =>
                    Navigator.pushNamed(context, '/slots/${widget.partnerId}'),
          ),
          _statTile(
            context,
            'Nombre total de réservations',
            totalBookings?.toString() ?? '…',
            onTap:
                () => Navigator.pushNamed(
                  context,
                  '/bookings/${widget.partnerId}',
                ),
          ),
          _statTile(
            context,
            'Taux de remplissage',
            fillRate != null ? '${(fillRate! * 100).round()} %' : '…',
          ),
          const Divider(height: 32),
          const Text(
            '📅 Calendrier des créneaux',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          PartnerSlotsCalendar(partnerId: widget.partnerId),
        ],
      ),
    );
  }

  Widget _statTile(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.analytics_outlined, color: Colors.deepPurple.shade300),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (onTap != null) const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
