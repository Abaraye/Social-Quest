// lib/screens/partners/partner_detail_page.dart

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
      appBar: AppBar(title: Text(widget.partner.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.partner.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Créneaux disponibles :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children:
                  slots.keys.map((slot) {
                    return ChoiceChip(
                      label: Text(slot),
                      selected: selectedSlot == slot,
                      onSelected: (_) {
                        setState(() {
                          selectedSlot = slot;
                          selectedDiscount =
                              null; // reset reduction quand créneau change
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),

            if (selectedSlot != null) ...[
              Text(
                'Réductions disponibles :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children:
                    slots[selectedSlot!]!.map((reduction) {
                      return ChoiceChip(
                        label: Text(reduction),
                        selected: selectedDiscount == reduction,
                        onSelected: (_) {
                          setState(() {
                            selectedDiscount = reduction;
                          });
                        },
                      );
                    }).toList(),
              ),
            ],

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (selectedSlot != null && selectedDiscount != null)
                        ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Réservation confirmée à $selectedSlot avec "$selectedDiscount" !',
                              ),
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (selectedSlot != null && selectedDiscount != null)
                          ? Colors.green
                          : Colors.grey,
                ),
                child: Text('Réserver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
