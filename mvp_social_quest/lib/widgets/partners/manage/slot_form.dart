// lib/widgets/partners/manage/slot_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManagePartnerSlotForm extends StatelessWidget {
  final DateTime? selectedDateTime;
  final TextEditingController reductionAmountController;
  final TextEditingController groupSizeController;
  final VoidCallback onPickDateTime;
  final VoidCallback onAddSlot;

  const ManagePartnerSlotForm({
    super.key,
    required this.selectedDateTime,
    required this.reductionAmountController,
    required this.groupSizeController,
    required this.onPickDateTime,
    required this.onAddSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              selectedDateTime == null
                  ? 'Choisir date et heure'
                  : DateFormat('dd/MM/yyyy - HH:mm').format(selectedDateTime!),
            ),
            onPressed: onPickDateTime,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: reductionAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Réduction %'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: groupSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Nb personnes'),
          ),
        ),
        IconButton(
          onPressed: onAddSlot,
          icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
        ),
      ],
    );
  }
}
