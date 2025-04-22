// =============================================================
// lib/widgets/partners/manage/slot_card.dart
// =============================================================
// 📅 Composant visuel pour afficher un créneau
// ✅ Affiche date, réduction, récurrence
// ❌ Menu suppression unique ou récurrence si applicable
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SlotCard extends StatelessWidget {
  final DateTime startTime;
  final Map<String, dynamic>? recurrence;
  final List<Map<String, dynamic>> reductions;
  final VoidCallback onDelete;
  final VoidCallback? onDeleteGroup;

  const SlotCard({
    super.key,
    required this.startTime,
    required this.reductions,
    required this.onDelete,
    this.recurrence,
    this.onDeleteGroup,
  });

  @override
  Widget build(BuildContext context) {
    final hasGroup = recurrence != null && onDeleteGroup != null;
    final formatted = DateFormat(
      'EEE d MMM à HH:mm',
      'fr_FR',
    ).format(startTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          formatted,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reductions.isNotEmpty)
              Text(
                '↓ ${reductions.first['amount']}% pour ${reductions.first['groupSize']} pers',
                style: const TextStyle(fontSize: 13),
              ),
            if (recurrence != null)
              Text(
                'Récurrence : ${recurrence!['type']}',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing:
            hasGroup
                ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'one') onDelete();
                    if (value == 'all') onDeleteGroup?.call();
                  },
                  itemBuilder:
                      (ctx) => [
                        const PopupMenuItem(
                          value: 'one',
                          child: Text('Supprimer ce créneau'),
                        ),
                        const PopupMenuItem(
                          value: 'all',
                          child: Text('Supprimer toute la récurrence'),
                        ),
                      ],
                )
                : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer ce créneau',
                  onPressed: onDelete,
                ),
      ),
    );
  }
}
