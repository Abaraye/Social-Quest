import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/partner.dart';
import '../../services/firestore_service.dart';

/// Écran qui affiche les détails d'un partenaire (activité)
/// ainsi que les créneaux disponibles et leurs réductions.
class PartnerDetailPage extends StatefulWidget {
  final Partner partner;

  const PartnerDetailPage({Key? key, required this.partner}) : super(key: key);

  @override
  State<PartnerDetailPage> createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  Map<String, dynamic>? selectedSlot;
  List<Map<String, dynamic>> slots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  /// 🔁 Récupère tous les slots du partenaire
  Future<void> _loadSlots() async {
    final fetchedSlots = await FirestoreService.getPartnerSlots(
      widget.partner.id,
    );
    setState(() {
      slots = fetchedSlots;
      isLoading = false;
    });
  }

  /// 🔧 Formatage d'une réduction pour l'affichage
  String _formatReduction(Map<String, dynamic> r) {
    final amount = r['amount'];
    final groupSize = r['groupSize'];
    return "-$amount% dès $groupSize personne${groupSize > 1 ? 's' : ''}";
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
                    // 🔹 Description de l'activité
                    Text(
                      widget.partner.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Liste des créneaux disponibles
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
                                setState(() => selectedSlot = slot);
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Réductions du créneau sélectionné
                    if (selectedSlot != null &&
                        selectedSlot!['reductions'] != null &&
                        selectedSlot!['reductions'] is List)
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
                                final label = _formatReduction(r);
                                return Chip(
                                  label: Text(label),
                                  backgroundColor: Colors.green.shade50,
                                );
                              }),
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    // 🔹 Bouton "Réserver"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        onPressed:
                            selectedSlot != null
                                ? () {
                                  final formatted = DateFormat(
                                    'dd/MM/yyyy - HH:mm',
                                  ).format(
                                    (selectedSlot!['startTime'] as Timestamp)
                                        .toDate(),
                                  );

                                  // 👉 Affichage d’un modal de confirmation
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder:
                                        (_) => Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Réservation Confirmée 🎉',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                '${widget.partner.name}\n$formatted',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.deepPurple,
                                                  minimumSize:
                                                      const Size.fromHeight(50),
                                                ),
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text(
                                                  'Fermer',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              selectedSlot != null
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
