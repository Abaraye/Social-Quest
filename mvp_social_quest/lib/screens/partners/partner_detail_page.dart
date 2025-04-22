import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/partner.dart';
import '../../services/firestore/slot_service.dart';
import '../../services/firestore/booking_service.dart';

/// 🧾 Page de détail d’un partenaire (activité)
/// Affiche la description, les créneaux disponibles, les réductions
/// Permet à l’utilisateur de réserver un créneau avec une réduction
class PartnerDetailPage extends StatefulWidget {
  final Partner partner;

  const PartnerDetailPage({super.key, required this.partner});

  @override
  State<PartnerDetailPage> createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  List<Map<String, dynamic>> slots = [];
  Map<String, dynamic>? selectedSlot;
  Map<String, dynamic>? selectedReduction;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots(); // Chargement initial des créneaux
  }

  /// 🔁 Récupère les créneaux disponibles depuis Firebase (y compris récurrents)
  Future<void> _loadSlots() async {
    final fetchedSlots = await SlotService.getExpandedPartnerSlots(
      widget.partner.id,
    );
    setState(() {
      slots = fetchedSlots;
      isLoading = false;
    });
  }

  /// 🧮 Formatte une réduction pour affichage
  String _formatReduction(Map<String, dynamic> r) {
    final amount = r['amount'];
    final groupSize = r['groupSize'];
    return "-$amount% dès $groupSize personne${groupSize > 1 ? 's' : ''}";
  }

  /// ✅ Effectue la réservation en appelant BookingService et affiche une confirmation
  Future<void> _confirmReservation() async {
    final slotId = selectedSlot!['id'];

    await BookingService.createBooking(
      partnerId: widget.partner.id,
      slotId: slotId,
      selectedReduction: selectedReduction!,
    );

    // 🎉 Affichage d’un bottom sheet de confirmation
    final formatted = DateFormat(
      'dd/MM/yyyy - HH:mm',
    ).format((selectedSlot!['startTime'] as Timestamp).toDate());

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Réservation Confirmée 🎉",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.partner.name}\n$formatted\n${_formatReduction(selectedReduction!)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white),
                  ),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📝 Description de l’activité
                    Text(
                      widget.partner.description,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // 🕒 Sélection des créneaux disponibles
                    const Text(
                      '🕒 Créneaux disponibles',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children:
                          slots.map((slot) {
                            final timestamp = slot['startTime'] as Timestamp;
                            final formatted = DateFormat(
                              'dd/MM/yyyy - HH:mm',
                            ).format(timestamp.toDate());
                            return ChoiceChip(
                              label: Text(formatted),
                              selected: selectedSlot == slot,
                              selectedColor: Colors.deepPurple.shade100,
                              onSelected: (_) {
                                setState(() {
                                  selectedSlot = slot;
                                  selectedReduction = null;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 🎁 Réductions disponibles pour le créneau sélectionné
                    if (selectedSlot?['reductions'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎁 Réductions disponibles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: List<Widget>.from(
                              (selectedSlot!['reductions'] as List).map((r) {
                                return ChoiceChip(
                                  label: Text(_formatReduction(r)),
                                  selected: selectedReduction == r,
                                  onSelected:
                                      (_) =>
                                          setState(() => selectedReduction = r),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    // ✅ Bouton de réservation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        onPressed:
                            selectedSlot != null && selectedReduction != null
                                ? _confirmReservation
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedSlot != null && selectedReduction != null
                                  ? Colors.green
                                  : Colors.grey.shade400,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        label: const Text('Réserver'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
