// =============================================================
// lib/widgets/partners/manage/recurring_slot_form.dart
// =============================================================
// 📆 Widget permettant de configurer une récurrence (fréquence, fin, etc.)
// Utilisé dans `ManagePartnerSlotsPage`
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecurringSlotForm extends StatelessWidget {
  final String recurrenceType;
  final void Function(String) onRecurrenceChanged;
  final DateTime? endDate;
  final void Function(DateTime?) onEndDateChanged;

  const RecurringSlotForm({
    super.key,
    required this.recurrenceType,
    required this.onRecurrenceChanged,
    required this.endDate,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final recurrenceOptions = [
      'Aucune',
      'Tous les jours',
      'Chaque semaine',
      'Tous les lundis',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: recurrenceType,
          items:
              recurrenceOptions.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
          onChanged: (v) => onRecurrenceChanged(v ?? 'Aucune'),
          decoration: const InputDecoration(labelText: 'Récurrence'),
        ),
        const SizedBox(height: 8),
        if (recurrenceType != 'Aucune')
          Row(
            children: [
              const Text('Jusqu’au :'),
              const SizedBox(width: 12),
              Text(
                endDate != null
                    ? DateFormat('dd/MM/yyyy').format(endDate!)
                    : 'Aucune date',
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  onEndDateChanged(date);
                },
              ),
            ],
          ),
      ],
    );
  }
}
