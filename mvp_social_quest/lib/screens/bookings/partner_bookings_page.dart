import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../services/firestore/booking_service.dart';

/// Affiche la liste des réservations pour un partenaire donné.
class PartnerBookingsPage extends StatelessWidget {
  final String partnerId;
  const PartnerBookingsPage({Key? key, required this.partnerId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations du partenaire'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Booking>>(
        stream: BookingService.streamForPartner(partnerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(
              child: Text('Aucune réservation', style: TextStyle(fontSize: 16)),
            );
          }
          // Trie par date
          bookings.sort((a, b) => a.occurrence.compareTo(b.occurrence));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final b = bookings[index];
              final dateStr = DateFormat(
                'dd/MM/yyyy – HH:mm',
              ).format(b.occurrence);
              return ListTile(
                title: Text(dateStr),
                subtitle: Text(
                  '-${b.reductionChosen.amount}% dès ${b.reductionChosen.groupSize} pers',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Oui'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      await BookingService.deleteBooking(b.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
