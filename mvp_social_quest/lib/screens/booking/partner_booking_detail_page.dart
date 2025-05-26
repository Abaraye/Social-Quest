import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mvp_social_quest/models/booking.dart';
import 'package:mvp_social_quest/screens/explore/quest_detail_page.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/providers/quest_provider.dart';
import '../../core/providers/service_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class PartnerBookingDetailsPage extends ConsumerWidget {
  final String bookingId;
  const PartnerBookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail réservation')),
      body: AsyncValueWidget<Booking?>(
        value: bookingAsync,
        dataBuilder: (b) {
          if (b == null) {
            return const Center(child: Text('Réservation introuvable'));
          }

          final questAsync = ref.watch(questProvider(b.questId));

          return AsyncValueWidget(
            value: questAsync,
            dataBuilder: (quest) {
              final date = DateFormat.yMMMMEEEEd(
                'fr_FR',
              ).add_Hm().format(b.startTime);
              final price = (b.totalPriceCents / 100).toStringAsFixed(2);

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest?.title ?? 'Activité inconnue',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.blue),
                    ),

                    const SizedBox(height: 16),
                    Text('📅 Date : $date'),
                    Text('👥 Personnes : ${b.peopleCount}'),
                    Text('💶 Montant : $price ${b.currency}'),
                    const SizedBox(height: 12),
                    Text(
                      '📌 Statut : ${b.status}',
                      style: TextStyle(
                        color:
                            b.status == 'cancelled' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (b.status != 'cancelled')
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            final bookingService = ref.read(
                              bookingServiceProvider,
                            );
                            final confirmed = await bookingService
                                .cancelBookingWithConfirmation(
                                  context,
                                  b.id,
                                  useRootNavigator: false,
                                );

                            if (confirmed && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Réservation annulée."),
                                ),
                              );
                              Navigator.of(
                                context,
                              ).pop(); // ✅ ferme BookingDetailsPage
                            }
                          },
                          child: const Text("Annuler la réservation"),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
