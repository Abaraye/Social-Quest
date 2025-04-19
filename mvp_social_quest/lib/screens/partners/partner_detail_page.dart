import 'package:flutter/material.dart';
import '../../models/partner.dart';

class PartnerDetailPage extends StatefulWidget {
  final Partner partner;

  const PartnerDetailPage({Key? key, required this.partner}) : super(key: key);

  @override
  State<PartnerDetailPage> createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  String? selectedSlot;
  String? selectedDiscount;

  @override
  Widget build(BuildContext context) {
    final slots = widget.partner.slots;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partner.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Description
            Text(
              widget.partner.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // — Créneaux
            const Text(
              '🕒 Créneaux disponibles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children:
                  slots.keys.map((slot) {
                    return ChoiceChip(
                      label: Text(slot),
                      selected: selectedSlot == slot,
                      selectedColor: Colors.deepPurple.shade100,
                      onSelected: (_) {
                        setState(() {
                          selectedSlot = slot;
                          selectedDiscount = null; // reset
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // — Réductions
            if (selectedSlot != null) ...[
              const Text(
                '🎁 Réductions disponibles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children:
                    slots[selectedSlot!]!.map((reduction) {
                      return ChoiceChip(
                        label: Text(reduction),
                        selected: selectedDiscount == reduction,
                        selectedColor: Colors.green.shade100,
                        onSelected: (_) {
                          setState(() {
                            selectedDiscount = reduction;
                          });
                        },
                      );
                    }).toList(),
              ),
            ],

            const Spacer(),

            // — Bouton Réserver
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.white),
                onPressed:
                    (selectedSlot != null && selectedDiscount != null)
                        ? () {
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
                                        '${widget.partner.name}\n$selectedSlot • $selectedDiscount',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          minimumSize: const Size.fromHeight(
                                            50,
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
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
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (selectedSlot != null && selectedDiscount != null)
                          ? Colors.green
                          : Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                label: const Text(
                  'Réserver',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
