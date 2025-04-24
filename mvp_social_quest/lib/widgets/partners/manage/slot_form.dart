import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formulaire de création rapide d’un créneau (date+heure + réduction).
/// Ne contient pas la logique Firestore – on la remonte au parent.
class ManagePartnerSlotForm extends StatelessWidget {
  final DateTime? selectedDateTime;
  final TextEditingController reductionAmountController;
  final TextEditingController groupSizeController;
  final VoidCallback onPickDateTime;
  final VoidCallback onAddSlot;
  const ManagePartnerSlotForm({
    Key? key,
    required this.selectedDateTime,
    required this.reductionAmountController,
    required this.groupSizeController,
    required this.onPickDateTime,
    required this.onAddSlot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Choix date+heure
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickDateTime,
            icon: const Icon(Icons.date_range),
            label: Text(
              selectedDateTime == null
                  ? 'Choisir date & heure'
                  : DateFormat('dd/MM/yyyy – HH:mm').format(selectedDateTime!),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // % réduction
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: reductionAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '%', isDense: true),
          ),
        ),
        const SizedBox(width: 8),
        // Taille du groupe
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: groupSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pers.',
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Bouton ajouter
        IconButton(
          icon: const Icon(
            Icons.add_circle,
            size: 32,
            color: Colors.deepPurple,
          ),
          tooltip: 'Ajouter',
          onPressed: onAddSlot,
        ),
      ],
    );
  }
}
