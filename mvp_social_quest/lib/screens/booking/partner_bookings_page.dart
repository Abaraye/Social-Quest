import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // ✅ Ajout

import '../../core/providers/booking_provider.dart';
import '../../core/providers/quest_provider.dart';
import '../../widgets/common/async_value_widget.dart';
import '../explore/quest_detail_page.dart';

class PartnerBookingsPage extends ConsumerWidget {
  final String partnerId;
  const PartnerBookingsPage({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(partnerBookingListProvider(partnerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations'),
        automaticallyImplyLeading: false,
      ),
      body: AsyncValueWidget(
        value: bookings,
        dataBuilder: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aucune réservation.'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final booking = list[i];
              final questAsync = ref.watch(questProvider(booking.questId));

              return AsyncValueWidget(
                value: questAsync,
                dataBuilder: (quest) {
                  final date = DateFormat.yMMMMEEEEd(
                    'fr_FR',
                  ).add_Hm().format(booking.startTime);
                  final price = (booking.totalPriceCents / 100).toStringAsFixed(
                    2,
                  );

                  return ListTile(
                    onTap: () {
                      context.push(
                        '/dashboard/$partnerId/booking/${booking.id}',
                      );
                    },
                    title: Text(
                      quest?.title ?? 'Activité inconnue',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.blue),
                    ),

                    subtitle: Text('$date – ${booking.peopleCount} pers.'),
                    trailing: Text('$price €'),
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
