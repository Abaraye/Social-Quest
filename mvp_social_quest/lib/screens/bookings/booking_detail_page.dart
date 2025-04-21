import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/partner.dart';
import '../../services/firestore/partner_service.dart';
import '../../services/firestore/booking_service.dart';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  Partner? partner;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartner();
  }

  Future<void> _loadPartner() async {
    try {
      final fetchedPartner = await PartnerService.getPartnerById(
        widget.booking.partnerId,
      );
      setState(() {
        partner = fetchedPartner;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.booking.startTime.toDate();
    final formattedDate = DateFormat(
      'EEEE dd MMMM yyyy • HH:mm',
      'fr_FR',
    ).format(start);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la réservation'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Activité réservée",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      partner?.name ?? 'Activité inconnue',
                      style: const TextStyle(fontSize: 20),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Date & heure",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(formattedDate),

                    const SizedBox(height: 24),
                    const Text(
                      "Réduction appliquée",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "-${widget.booking.reductionChosen['amount']}% dès ${widget.booking.reductionChosen['groupSize']} personnes",
                    ),

                    if (partner?.address != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        "Adresse",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(partner!.address!),
                    ],

                    const Spacer(),

                    if (start.isAfter(DateTime.now()))
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text(
                                    "Annuler cette réservation ?",
                                  ),
                                  content: const Text(
                                    "Cette action est irréversible.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
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
                            await BookingService.deleteBooking(
                              widget.booking.id,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Réservation annulée."),
                                ),
                              );
                            }
                          }
                        },
                        label: const Text(
                          "Annuler la réservation",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
