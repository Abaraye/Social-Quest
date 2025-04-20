// lib/widgets/partners/manage/slot_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePartnerSlotList extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final String partnerId;
  final void Function(List<Map<String, dynamic>>) onSlotsUpdated;

  const ManagePartnerSlotList({
    super.key,
    required this.slots,
    required this.partnerId,
    required this.onSlotsUpdated,
  });

  Future<void> _editReduction(
    BuildContext context,
    String slotId,
    int index,
    Map<String, dynamic> oldReduction,
  ) async {
    final newAmountController = TextEditingController(
      text: oldReduction['amount'].toString(),
    );
    final newGroupSizeController = TextEditingController(
      text: oldReduction['groupSize'].toString(),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Modifier la réduction"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "% réduction"),
                ),
                TextField(
                  controller: newGroupSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Nb personnes"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'amount':
                        int.tryParse(newAmountController.text.trim()) ?? 0,
                    'groupSize':
                        int.tryParse(newGroupSizeController.text.trim()) ?? 1,
                  });
                },
                child: const Text("Enregistrer"),
              ),
            ],
          ),
    );

    if (result != null) {
      final slotRef = FirebaseFirestore.instance
          .collection('partners')
          .doc(partnerId)
          .collection('slots')
          .doc(slotId);

      final slot = slots.firstWhere((s) => s['id'] == slotId);
      final updatedReductions = List<Map<String, dynamic>>.from(
        slot['reductions'],
      );
      updatedReductions[index] = result;

      await slotRef.update({'reductions': updatedReductions});
      slot['reductions'] = updatedReductions;

      onSlotsUpdated([...slots]);
    }
  }

  Future<void> _deleteReduction(String slotId, int index) async {
    final docRef = FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId);

    final slot = slots.firstWhere((s) => s['id'] == slotId);
    final updatedReductions = List<Map<String, dynamic>>.from(
      slot['reductions'],
    );
    updatedReductions.removeAt(index);

    await docRef.update({'reductions': updatedReductions});
    slot['reductions'] = updatedReductions;

    onSlotsUpdated([...slots]);
  }

  Future<void> _addReduction(BuildContext context, String slotId) async {
    final amountController = TextEditingController();
    final groupSizeController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Ajouter une réduction"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "% réduction"),
                ),
                TextField(
                  controller: groupSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Nb personnes"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'amount': int.tryParse(amountController.text.trim()) ?? 0,
                    'groupSize':
                        int.tryParse(groupSizeController.text.trim()) ?? 1,
                  });
                },
                child: const Text("Ajouter"),
              ),
            ],
          ),
    );

    if (result != null) {
      final slotRef = FirebaseFirestore.instance
          .collection('partners')
          .doc(partnerId)
          .collection('slots')
          .doc(slotId);

      final slot = slots.firstWhere((s) => s['id'] == slotId);
      final updatedReductions = List<Map<String, dynamic>>.from(
        slot['reductions'],
      );
      updatedReductions.add(result);

      await slotRef.update({'reductions': updatedReductions});
      slot['reductions'] = updatedReductions;

      onSlotsUpdated([...slots]);
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    await FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slotId)
        .delete();

    onSlotsUpdated(slots.where((s) => s['id'] != slotId).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          slots.map((slot) {
            final slotId = slot['id'];
            final date = (slot['startTime'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(date);
            final reductions = (slot['reductions'] ?? []) as List;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(reductions.length, (index) {
                      final r = reductions[index];
                      return InputChip(
                        label: Text("-${r['amount']}% dès ${r['groupSize']}p"),
                        onPressed:
                            () => _editReduction(context, slotId, index, r),
                        onDeleted: () => _deleteReduction(slotId, index),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addReduction(context, slotId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSlot(slotId),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
