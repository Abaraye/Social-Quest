import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/booking_provider.dart';
import '../../core/providers/quest_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class BookingPage extends ConsumerWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
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
                  final total = (booking.totalPriceCents / 100).toStringAsFixed(
                    2,
                  );

                  return ListTile(
                    title: Text(quest?.title ?? 'Activité inconnue'),
                    subtitle: Text('$date – ${booking.peopleCount} pers.'),
                    trailing: Text('$total €'),
                    onTap: () => context.push('/home/booking/${booking.id}'),
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
