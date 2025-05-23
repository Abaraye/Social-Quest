import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
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
        dataBuilder:
            (list) =>
                list.isEmpty
                    ? const Center(child: Text('Aucune réservation.'))
                    : ListView.builder(
                      itemCount: list.length,
                      itemBuilder:
                          (_, i) => ListTile(
                            title: Text('Quête ${list[i].questId}'),
                            subtitle: Text(
                              '${list[i].peopleCount} pers. – ${list[i].status}',
                            ),
                            onTap:
                                () => Navigator.of(
                                  context,
                                ).pushNamed('/booking/${list[i].id}'),
                          ),
                    ),
      ),
    );
  }
}
