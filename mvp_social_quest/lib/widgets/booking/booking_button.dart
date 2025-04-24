// lib/widgets/booking/booking_button.dart
import 'package:flutter/material.dart';
import '../../models/reduction.dart';
import '../../services/firestore/booking_service.dart';

/// 🟢 Bouton pour réserver un créneau.
/// Délégué BookingService pour la logique métier.
class BookingButton extends StatefulWidget {
  final String partnerId;
  final String slotId;
  final Reduction selectedReduction;
  final DateTime startTime;

  const BookingButton({
    Key? key,
    required this.partnerId,
    required this.slotId,
    required this.selectedReduction,
    required this.startTime,
  }) : super(key: key);

  @override
  State<BookingButton> createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  bool _isLoading = false;
  bool _isBooked = false;

  Future<void> _bookSlot() async {
    if (_isBooked) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await BookingService.createBooking(
        partnerId: widget.partnerId,
        slotId: widget.slotId,
        occurrence: widget.startTime,
        selectedReduction: widget.selectedReduction.toMap(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation confirmée 🎉')),
        );
        setState(() {
          _isBooked = true;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: (_isLoading || _isBooked) ? null : _bookSlot,
      icon:
          _isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.check_circle),
      label: Text(_isBooked ? 'Déjà réservé' : 'Réserver ce créneau'),
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}
