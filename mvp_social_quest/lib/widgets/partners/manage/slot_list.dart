import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/slot.dart';
import '../../../services/firestore/slot_service.dart';

/// Liste de slots avec leurs réductions et options de suppression.
/// Délègue la suppression au service et notifie le parent via [onSlotsChanged].
class ManagePartnerSlotList extends StatelessWidget {
  final List<Slot> slots;
  final String partnerId;
  final VoidCallback onSlotsChanged;

  const ManagePartnerSlotList({
    Key? key,
    required this.slots,
    required this.partnerId,
    required this.onSlotsChanged,
  }) : super(key: key);

  Future<void> _deleteOccurrence(BuildContext ctx, Slot slot) async {
    await SlotService.deleteSingleOccurrence(
      partnerId,
      slot.id,
      slot.startTime,
    );
    onSlotsChanged();
  }

  Future<void> _deleteSeries(Slot slot) async {
    if (slot.recurrenceGroupId != null) {
      await SlotService.deleteRecurrenceGroup(
        partnerId,
        slot.recurrenceGroupId!,
      );
      onSlotsChanged();
    }
  }

  Future<void> _deleteOneOff(Slot slot) async {
    // Delete direct document for a one-off slot
    await FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .doc(slot.id)
        .delete();
    onSlotsChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Center(child: Text('Aucun créneau'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final slot = slots[i];
        final formatted = DateFormat(
          'dd/MM/yyyy – HH:mm',
        ).format(slot.startTime);
        final hasSeries =
            slot.recurrence != null && slot.recurrenceGroupId != null;

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              formatted,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              slot.reductions.isNotEmpty
                  ? '-${slot.reductions.first.amount}% dès ${slot.reductions.first.groupSize}p'
                  : 'Aucune réduction',
            ),
            trailing:
                hasSeries
                    ? PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'one')
                          await _deleteOccurrence(context, slot);
                        if (value == 'all') await _deleteSeries(slot);
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
                      tooltip: 'Supprimer',
                      onPressed: () => _deleteOneOff(slot),
                    ),
          ),
        );
      },
    );
  }
}
