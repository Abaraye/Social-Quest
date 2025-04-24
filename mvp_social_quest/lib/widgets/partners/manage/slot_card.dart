import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/reduction.dart';

/// Affiche un créneau avec ses réductions et options de suppression.
class SlotCard extends StatelessWidget {
  final DateTime startTime;
  final List<Reduction> reductions;
  final Map<String, dynamic>? recurrence;
  final VoidCallback onDelete;
  final VoidCallback? onDeleteSeries;

  const SlotCard({
    Key? key,
    required this.startTime,
    required this.reductions,
    required this.onDelete,
    this.recurrence,
    this.onDeleteSeries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat(
      'EEE d MMM à HH:mm',
      'fr_FR',
    ).format(startTime);
    final hasSeries = recurrence != null && onDeleteSeries != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          formatted,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reductions.isNotEmpty)
              Text(
                '– ${reductions.first.amount}% dès ${reductions.first.groupSize} pers',
              ),
            if (recurrence != null)
              Text(
                'Récurrence : ${recurrence!['type']}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing:
            hasSeries
                ? PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'one') onDelete();
                    if (v == 'all') onDeleteSeries!();
                  },
                  itemBuilder:
                      (_) => const [
                        PopupMenuItem(
                          value: 'one',
                          child: Text('Cette occurrence'),
                        ),
                        PopupMenuItem(
                          value: 'all',
                          child: Text('Toute la série'),
                        ),
                      ],
                )
                : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
      ),
    );
  }
}
