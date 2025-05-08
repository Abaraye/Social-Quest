import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;
  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Réservation $bookingId')),
    body: Center(child: Text('Détails de la réservation : $bookingId')),
  );
}
