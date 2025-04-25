import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/validators.dart'; // 🆕
import '../../../services/firestore/recurrence_helper.dart';

/// Widget de configuration de récurrence d’un slot.
class RecurringSlotForm extends StatelessWidget {
  final String recurrenceType;
  final DateTime? endDate;
  final DateTime initialStart;
  final int? priceCents; // 🆕 pré-remplissage
  final ValueChanged<String> onRecurrenceChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<int> onPriceCentsChanged; // 🆕 callback

  const RecurringSlotForm({
    Key? key,
    required this.recurrenceType,
    required this.endDate,
    required this.initialStart,
    this.priceCents,
    required this.onRecurrenceChanged,
    required this.onEndDateChanged,
    required this.onPriceCentsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = ['Aucune', 'Tous les jours', 'Chaque semaine'];
    final preview =
        (recurrenceType != 'Aucune' && endDate != null)
            ? RecurrenceHelper.generateOccurrences(
              slotStart: initialStart,
              type: recurrenceType,
              endDate: endDate!,
            )
            : <DateTime>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Prix TTC -------------------------------------------------------
        TextFormField(
          initialValue:
              priceCents != null
                  ? (priceCents! / 100).toStringAsFixed(2)
                  : null,
          decoration: const InputDecoration(
            labelText: 'Prix TTC (€)',
            prefixIcon: Icon(Icons.euro),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: FormValidators.priceRange(),
          onChanged: (v) {
            final euros = double.tryParse(v.replaceAll(',', '.'));
            if (euros != null) onPriceCentsChanged((euros * 100).round());
          },
        ),
        const SizedBox(height: 12),

        // --- Choix récurrence ----------------------------------------------
        DropdownButtonFormField<String>(
          value: recurrenceType,
          decoration: const InputDecoration(labelText: 'Récurrence'),
          items:
              options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
          onChanged: (v) => onRecurrenceChanged(v ?? 'Aucune'),
        ),
        if (recurrenceType != 'Aucune') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                endDate != null
                    ? DateFormat('dd/MM/yyyy').format(endDate!)
                    : 'Jusqu’au :',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate:
                        endDate ?? initialStart.add(const Duration(days: 7)),
                    firstDate: initialStart,
                    lastDate: initialStart.add(const Duration(days: 365)),
                  );
                  onEndDateChanged(d);
                },
              ),
            ],
          ),
        ],
        if (preview.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Aperçu des dates :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 4,
            children:
                preview
                    .map(
                      (d) => Chip(label: Text(DateFormat('dd/MM').format(d))),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }
}
