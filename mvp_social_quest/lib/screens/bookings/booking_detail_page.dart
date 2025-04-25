import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/price_calculator.dart'; // 🆕
import '../../models/booking.dart';
import '../../models/partner/partner.dart';
import '../../services/firestore/booking_service.dart';
import '../../services/firestore/partner/partner_service.dart';

/// Affiche le détail d’une réservation (infos activité + date + réduction + annulation).
class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEEE dd MMMM yyyy • HH:mm', 'fr_FR');
    final moneyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    final netCents = PriceCalculator.netPriceCents(
      booking.priceCents,
      booking.reductionChosen.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la réservation'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Partner>(
        future: PartnerService.getPartnerById(booking.partnerId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final partner = snap.data;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activité réservée',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  partner?.name ?? 'Activité inconnue',
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Date & heure',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(dateFmt.format(booking.occurrence)),

                const SizedBox(height: 24),
                const Text(
                  'Tarification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Prix initial : '),
                        Text(
                          moneyFmt.format(booking.priceCents / 100),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Réduction : '),
                        Text('-${booking.reductionChosen.amount}%'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Total : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          moneyFmt.format(netCents / 100),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Détail réduction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '-${booking.reductionChosen.amount}% dès ${booking.reductionChosen.groupSize} pers',
                ),

                if (partner?.address != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Adresse',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(partner!.address!),
                ],

                const Spacer(),

                if (booking.occurrence.isAfter(DateTime.now()))
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler la réservation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Annuler cette réservation ?'),
                              content: const Text(
                                'Cette action est irréversible.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Non'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Oui, annuler'),
                                ),
                              ],
                            ),
                      );
                      if (ok == true) {
                        await BookingService.instance.deleteBooking(booking.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Réservation annulée.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
