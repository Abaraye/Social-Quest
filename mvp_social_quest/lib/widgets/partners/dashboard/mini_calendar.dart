import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../models/slot.dart';
import '../../../services/firestore/slot_service.dart';

/// Mini-calendrier interactif pour la gestion des créneaux.
class PartnerSlotsCalendar extends StatefulWidget {
  final String partnerId;
  const PartnerSlotsCalendar({Key? key, required this.partnerId})
    : super(key: key);

  @override
  State<PartnerSlotsCalendar> createState() => _PartnerSlotsCalendarState();
}

class _PartnerSlotsCalendarState extends State<PartnerSlotsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Slot>> _slotsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final allSlots = await SlotService.getExpandedPartnerSlots(
      widget.partnerId,
    );
    final map = <DateTime, List<Slot>>{};
    for (final slot in allSlots) {
      final key = DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      map.putIfAbsent(key, () => []).add(slot);
    }
    map.forEach(
      (_, list) => list.sort((a, b) => a.startTime.compareTo(b.startTime)),
    );
    setState(() => _slotsByDay = map);
  }

  List<Slot> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _slotsByDay[key] ?? [];
  }

  void _onSlotTap(Slot slot) {
    final dt = slot.startTime;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créneau le ${DateFormat('EEEE d MMMM HH:mm', 'fr_FR').format(dt)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                for (final r in slot.reductions)
                  Text('Réduction : -${r.amount}% dès ${r.groupSize} pers'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: formulaire de modification
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        String choice = 'occurrence';
                        if (slot.recurrenceGroupId != null) {
                          final result = await showDialog<String>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Supprimer le créneau'),
                                  content: const Text(
                                    'Supprimer uniquement cette occurrence ou toute la série ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(
                                            context,
                                            'occurrence',
                                          ),
                                      child: const Text('Cette occurrence'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, 'serie'),
                                      child: const Text('Toute la série'),
                                    ),
                                  ],
                                ),
                          );
                          if (result != null) choice = result;
                        }

                        Navigator.pop(context);
                        if (choice == 'occurrence') {
                          await SlotService.deleteSingleOccurrence(
                            widget.partnerId,
                            slot.id,
                            slot.startTime,
                          );
                        } else {
                          await SlotService.deleteRecurrenceGroup(
                            widget.partnerId,
                            slot.recurrenceGroupId!,
                          );
                        }
                        await _loadSlots();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events =
        (_selectedDay != null) ? _getEventsForDay(_selectedDay!) : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 Calendrier des créneaux',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TableCalendar(
          locale: 'fr_FR',
          focusedDay: _focusedDay,
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          onDaySelected:
              (sel, foc) => setState(() {
                if (_selectedDay != null && isSameDay(_selectedDay, sel)) {
                  _selectedDay = null;
                } else {
                  _selectedDay = sel;
                }
                _focusedDay = foc;
              }),
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(markerSize: 6),
        ),
        const SizedBox(height: 12),
        if (_selectedDay != null && events.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView(
              children:
                  events
                      .map(
                        (slot) => ListTile(
                          title: Text(
                            DateFormat('HH:mm').format(slot.startTime),
                          ),
                          subtitle: Text(
                            '${slot.reductions.length} réduction(s)',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _onSlotTap(slot),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }
}
