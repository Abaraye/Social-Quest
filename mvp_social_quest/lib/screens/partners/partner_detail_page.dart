// lib/screens/partners/partner_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/slot.dart';
import '../../models/partner/partner.dart';
import '../../models/reduction.dart'; // ← import ajouté
import '../../services/firestore/slot_service.dart';
import '../../services/firestore/booking_service.dart';
import '../../widgets/common/rounded_button.dart';

/// 📋 Détail d’une activité + prise de réservation
/// Affiche la liste de créneaux (récurrents étendus) et gère la réservation.
class PartnerDetailPage extends StatefulWidget {
  final Partner partner;

  const PartnerDetailPage({Key? key, required this.partner}) : super(key: key);

  @override
  State<PartnerDetailPage> createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  late Future<List<Slot>> _slotsFuture;
  Slot? _selectedSlot;
  Reduction? _selectedReduction;

  @override
  void initState() {
    super.initState();
    // On charge en une fois la liste des occurrences à venir
    _slotsFuture = SlotService.getExpandedSlots(widget.partner.id);
  }

  Future<void> _confirmReservation() async {
    final slot = _selectedSlot!;
    final red = _selectedReduction!;
    await BookingService.createBooking(
      partnerId: widget.partner.id,
      slotId: slot.id,
      occurrence: slot.startTime,
      selectedReduction: red.toMap(),
    );

    final when = DateFormat('dd/MM/yyyy – HH:mm').format(slot.startTime);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Réservation Confirmée 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.partner.name}\n$when\n'
                  '-${red.amount}% dès ${red.groupSize} pers',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                RoundedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partner.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Slot>>(
        future: _slotsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final slots =
              snap.data!..sort((a, b) => a.startTime.compareTo(b.startTime));
          if (slots.isEmpty) {
            return const Center(child: Text('Aucun créneau disponible.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '📅 Sélectionnez un créneau',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Liste horizontale de ChoiceChips pour les dates
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: slots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final slot = slots[i];
                      final label = DateFormat(
                        'dd/MM • HH:mm',
                      ).format(slot.startTime);
                      return ChoiceChip(
                        label: Text(label),
                        selected: _selectedSlot == slot,
                        onSelected:
                            (_) => setState(() {
                              _selectedSlot = slot;
                              _selectedReduction = null;
                            }),
                      );
                    },
                  ),
                ),

                // Sélection de la réduction
                if (_selectedSlot?.reductions.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '🎁 Choisissez une réduction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _selectedSlot!.reductions.map((r) {
                          final label = '-${r.amount}% dès ${r.groupSize}p';
                          return ChoiceChip(
                            label: Text(label),
                            selected: _selectedReduction == r,
                            onSelected:
                                (_) => setState(() => _selectedReduction = r),
                          );
                        }).toList(),
                  ),
                ],

                const Spacer(),

                // Bouton Réserver
                RoundedButton(
                  onPressed:
                      (_selectedSlot != null && _selectedReduction != null)
                          ? _confirmReservation
                          : null,
                  child: Text(
                    'Réserver',
                    style: TextStyle(
                      color:
                          (_selectedSlot != null && _selectedReduction != null)
                              ? Colors.white
                              : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
