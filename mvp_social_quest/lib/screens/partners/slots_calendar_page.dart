// lib/screens/partners/slots_calendar_page.dart
// =============================================================
// 📅 Page dédiée au calendrier et stats de taux de remplissage
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/widgets/partners/dashboard/mini_calendar.dart';
import 'package:mvp_social_quest/services/firestore/stats_service.dart';
import 'package:intl/intl.dart';

class SlotsCalendarPage extends StatelessWidget {
  final String partnerId;
  final String partnerName;
  final double fillRate;

  const SlotsCalendarPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
    required this.fillRate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taux de remplissage'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(partnerName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Taux de remplissage moyen : ${(fillRate * 100).toStringAsFixed(1)} %',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            const Text(
              'Calendrier des créneaux',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: PartnerSlotsCalendar(partnerId: partnerId)),
          ],
        ),
      ),
    );
  }
}
