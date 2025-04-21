import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvp_social_quest/models/booking.dart';
import 'package:mvp_social_quest/screens/bookings/booking_detail_page.dart';
import 'package:mvp_social_quest/services/firestore/booking_service.dart';
import 'package:mvp_social_quest/services/firestore/partner_service.dart';

/// 🌏 Page "Mes réservations"
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool showUpcoming = true;

  Future<String> _getPartnerName(String partnerId) async {
    try {
      final partner = await PartnerService.getPartnerById(partnerId);
      return partner.name;
    } catch (_) {
      return "Activité inconnue";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes réservations"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
              showUpcoming ? Icons.history : Icons.schedule,
              color: Colors.white,
            ),
            onPressed: () => setState(() => showUpcoming = !showUpcoming),
            tooltip:
                showUpcoming
                    ? "Voir les réservations passées"
                    : "Voir les réservations à venir",
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream:
            showUpcoming
                ? BookingService.getUpcomingUserBookings()
                : BookingService.getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                showUpcoming
                    ? "Aucune réservation à venir"
                    : "Aucune réservation passée",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (_, index) {
              final booking = bookings[index];
              final start = booking.startTime.toDate();
              final formattedDate = DateFormat(
                'EEEE dd MMMM yyyy • HH:mm',
                'fr_FR',
              ).format(start);

              return FutureBuilder<String>(
                future: _getPartnerName(booking.partnerId),
                builder: (context, snapshot) {
                  final partnerName = snapshot.data ?? 'Chargement...';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailPage(booking: booking),
                        ),
                      );
                    },
                    onLongPress: () async {
                      if (start.isAfter(DateTime.now())) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Annuler la réservation ?"),
                                content: const Text(
                                  "Cette action est définitive.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Non"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Oui, annuler"),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await BookingService.deleteBooking(booking.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Réservation annulée."),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_available,
                              size: 32,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    partnerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "-${booking.reductionChosen['amount']}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  "dès ${booking.reductionChosen['groupSize']}p",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
