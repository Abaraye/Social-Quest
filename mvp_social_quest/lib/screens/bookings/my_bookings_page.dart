// lib/screens/bookings/my_bookings_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/firestore/booking_service.dart';
import '../../services/firestore/partner_service.dart';
import 'booking_detail_page.dart';

/// 🌏 Affiche les réservations de l’utilisateur (à venir / passées).
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool _showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    final stream =
        _showUpcoming
            ? BookingService.getUpcomingUserBookings()
            : BookingService.getUserBookings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(_showUpcoming ? Icons.history : Icons.schedule),
            tooltip: _showUpcoming ? 'Voir passées' : 'Voir à venir',
            onPressed: () => setState(() => _showUpcoming = !_showUpcoming),
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream: stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snap.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                _showUpcoming
                    ? 'Aucune réservation à venir'
                    : 'Aucune réservation passée',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (ctx, i) => _BookingTile(booking: bookings[i]),
          );
        },
      ),
    );
  }
}

/// 🔹 Widget privé pour afficher une réservation dans la liste.
class _BookingTile extends StatelessWidget {
  final Booking booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final start = booking.occurrence;
    final dateStr = DateFormat(
      'EEEE dd MMMM yyyy • HH:mm',
      'fr_FR',
    ).format(start);

    return FutureBuilder<String>(
      future: PartnerService.getPartnerById(
        booking.partnerId,
      ).then((p) => p.name),
      builder: (ctx, snap) {
        final name = snap.data ?? 'Chargement...';
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.event_available,
              color: Colors.deepPurple,
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dateStr),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '-${booking.reductionChosen.amount}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'dès ${booking.reductionChosen.groupSize}p',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingDetailPage(booking: booking),
                  ),
                ),
            onLongPress: () async {
              if (start.isAfter(DateTime.now())) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Annuler cette réservation ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Non'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Oui'),
                          ),
                        ],
                      ),
                );
                if (confirmed == true) {
                  await BookingService.deleteBooking(booking.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Réservation annulée.')),
                    );
                  }
                }
              }
            },
          ),
        );
      },
    );
  }
}
