import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/models/booking.dart';
import '../../core/providers/booking_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class BookingDetailsPage extends ConsumerWidget {
  final String bookingId;
  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail réservation')),
      body: AsyncValueWidget<Booking?>(
        value: booking,
        dataBuilder:
            (b) =>
                b == null
                    ? const Center(child: Text('Réservation introuvable'))
                    : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statut : ${b.status}'),
                          Text('Personnes : ${b.peopleCount}'),
                          Text(
                            'Montant : ${b.totalPriceCents / 100} ${b.currency}',
                          ),
                          Text('Début : ${b.startTime}'),
                        ],
                      ),
                    ),
      ),
    );
  }
}
