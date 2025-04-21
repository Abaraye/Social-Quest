// =============================================================
// lib/screens/bookings/partner_bookings_page.dart – v1.1
// =============================================================
// ✅ Affiche les réservations à venir pour une activité commerçante
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PartnerBookingsPage extends StatelessWidget {
  final String partnerId;

  const PartnerBookingsPage({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final bookingsQuery = FirebaseFirestore.instance
        .collection('bookings')
        .where('partnerId', isEqualTo: partnerId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('startTime');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Réservations à venir"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement."));
          }

          final bookings = snapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                "Aucune réservation à venir.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = bookings[i].data() as Map<String, dynamic>;
              final startTime = (data['startTime'] as Timestamp).toDate();
              final formattedTime = DateFormat(
                'EEEE dd MMM – HH:mm',
                'fr_FR',
              ).format(startTime);

              final userId = data['userId'] ?? 'Client inconnu';
              final reduction = data['reductionChosen']?['amount'] ?? 0;
              final groupSize = data['reductionChosen']?['groupSize'] ?? '?';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.deepPurple),
                  title: Text(formattedTime),
                  subtitle: Text(
                    "Client : $userId\nRéduction : -$reduction% (groupe de $groupSize)",
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
