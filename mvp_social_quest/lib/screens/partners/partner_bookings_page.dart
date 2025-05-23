import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartnerBookingsPage extends ConsumerWidget {
  final String partnerId;
  const PartnerBookingsPage({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations'),
        automaticallyImplyLeading: false,
      ),

      body: Center(child: Text('Bookings for partner $partnerId')),
    );
  }
}
