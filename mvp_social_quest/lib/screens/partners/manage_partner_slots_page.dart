// lib/screens/partners/manage_partner_slots_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManagePartnerSlotsPage extends StatefulWidget {
  final String partnerId;
  const ManagePartnerSlotsPage({Key? key, required this.partnerId})
    : super(key: key);

  @override
  State<ManagePartnerSlotsPage> createState() => _ManagePartnerSlotsPageState();
}

class _ManagePartnerSlotsPageState extends State<ManagePartnerSlotsPage> {
  final _firestore = FirebaseFirestore.instance;
  final DateFormat _fmt = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> _showSlotForm({
    DocumentSnapshot<Map<String, dynamic>>? existing,
  }) async {
    final startCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    DateTime? pickedDate =
        existing != null
            ? (existing.data()!['startTime'] as Timestamp).toDate()
            : null;

    if (existing != null) {
      priceCtrl.text = (existing.data()!['priceCents'] as int).toString();
      startCtrl.text = _fmt.format(pickedDate!);
    }

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              existing != null ? 'Modifier créneau' : 'Nouveau créneau',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date/heure
                TextFormField(
                  controller: startCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date & heure',
                    icon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: pickedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(
                        pickedDate ?? DateTime.now(),
                      ),
                    );
                    if (time == null) return;
                    pickedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                    startCtrl.text = _fmt.format(pickedDate!);
                  },
                ),
                const SizedBox(height: 16),
                // Prix en euros
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix (€)',
                    icon: Icon(Icons.euro),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (pickedDate == null || priceCtrl.text.isEmpty) return;
                  final cents = (double.tryParse(priceCtrl.text) ?? 0) * 100;
                  final data = {
                    'startTime': Timestamp.fromDate(pickedDate!),
                    'priceCents': cents.toInt(),
                    'currency': 'EUR',
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  final col = _firestore
                      .collection('partners')
                      .doc(widget.partnerId)
                      .collection('slots');
                  if (existing != null) {
                    await col.doc(existing.id).update(data);
                  } else {
                    data['createdAt'] = FieldValue.serverTimestamp();
                    await col.add(data);
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text(existing != null ? 'Enregistrer' : 'Créer'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteSlot(String slotId) async {
    await _firestore
        .collection('partners')
        .doc(widget.partnerId)
        .collection('slots')
        .doc(slotId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final slotsStream =
        _firestore
            .collection('partners')
            .doc(widget.partnerId)
            .collection('slots')
            .orderBy('startTime')
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les créneaux'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: slotsStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
              child: Text('Erreur de chargement des créneaux'),
            );
          }
          final slots = snap.data?.docs ?? [];
          if (slots.isEmpty) {
            return const Center(child: Text('Aucun créneau disponible'));
          }
          return ListView.builder(
            itemCount: slots.length,
            itemBuilder: (ctx, i) {
              final slot = slots[i];
              final data = slot.data();
              final dt = (data['startTime'] as Timestamp).toDate();
              final price = (data['priceCents'] as int) / 100;
              return ListTile(
                title: Text(_fmt.format(dt)),
                subtitle: Text('€${price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showSlotForm(existing: slot),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSlot(slot.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showSlotForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
