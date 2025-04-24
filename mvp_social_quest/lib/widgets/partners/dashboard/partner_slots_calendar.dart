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
  bool _loading = true, _error = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final allSlots = await SlotService.getExpandedSlots(widget.partnerId);
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
    } catch (_) {
      setState(() => _error = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Slot> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _slotsByDay[key] ?? [];
  }

  void _onSlotTap(Slot slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Créer le ${DateFormat.yMMMMEEEEd('fr_FR').add_Hm().format(slot.startTime)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...slot.reductions.map(
                  (r) => Text('– ${r.amount}% dès ${r.groupSize} pers'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (slot.recurrenceGroupId != null) {
                          final choice = await showDialog<String>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text(
                                    'Supprimer la récurrence ?',
                                  ),
                                  content: const Text(
                                    'Cette occurrence ou toute la série ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(
                                            context,
                                            'occurrence',
                                          ),
                                      child: const Text('Cette fois'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.pop(context, 'series'),
                                      child: const Text('Toute la série'),
                                    ),
                                  ],
                                ),
                          );
                          if (choice == 'series') {
                            await SlotService.deleteRecurrenceGroup(
                              widget.partnerId,
                              slot.recurrenceGroupId!,
                            );
                          } else {
                            await SlotService.deleteSingleOccurrence(
                              widget.partnerId,
                              slot.id,
                              slot.startTime,
                            );
                          }
                        } else {
                          await SlotService.updateSlot(
                            partnerId: widget.partnerId,
                            slotId: slot.id,
                            updates: {'deleted': true},
                          );
                        }
                        _loadSlots();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Supprimer'),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return Center(
        child: Text(
          'Erreur de chargement',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 Calendrier des créneaux',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TableCalendar<Slot>(
          locale: 'fr_FR',
          focusedDay: _focusedDay,
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          onDaySelected:
              (sel, foc) => setState(() {
                _selectedDay = isSameDay(sel, _selectedDay) ? null : sel;
                _focusedDay = foc;
              }),
          eventLoader: _eventsForDay,
          calendarStyle: const CalendarStyle(markerSize: 6),
        ),
        const SizedBox(height: 8),
        if (_selectedDay != null)
          SizedBox(
            height: 150,
            child:
                _eventsForDay(_selectedDay!).isEmpty
                    ? const Center(child: Text('Aucun créneau ce jour.'))
                    : ListView.builder(
                      itemCount: _eventsForDay(_selectedDay!).length,
                      itemBuilder: (_, i) {
                        final slot = _eventsForDay(_selectedDay!)[i];
                        return ListTile(
                          title: Text(DateFormat.Hm().format(slot.startTime)),
                          subtitle: Text(
                            '${slot.reductions.length} réduction(s)',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _onSlotTap(slot),
                        );
                      },
                    ),
          ),
      ],
    );
  }
}
