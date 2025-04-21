// lib/widgets/booking/booking_button.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/services/firestore/booking_service.dart';

/// 🟣 Bouton de réservation d’un créneau spécifique avec une réduction
class BookingButton extends StatefulWidget {
  final String partnerId;
  final String slotId;
  final Map<String, dynamic> selectedReduction;
  final DateTime startTime;

  const BookingButton({
    super.key,
    required this.partnerId,
    required this.slotId,
    required this.selectedReduction,
    required this.startTime,
  });

  @override
  State<BookingButton> createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  bool isLoading = false;

  Future<void> _bookSlot() async {
    setState(() => isLoading = true);

    try {
      await BookingService.createBooking(
        partnerId: widget.partnerId,
        slotId: widget.slotId,
        selectedReduction: {
          ...widget.selectedReduction,
          'startTime': Timestamp.fromDate(widget.startTime),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation confirmée ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _bookSlot,
      icon:
          isLoading
              ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.check_circle),
      label: const Text("Réserver ce créneau"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}
