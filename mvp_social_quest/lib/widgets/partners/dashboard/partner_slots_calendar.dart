// =============================================================
// lib/widgets/partners/dashboard/partner_slots_calendar.dart – v2.1
// =============================================================
// 📅 Affiche les créneaux du partenaire dans un calendrier interactif
// ✅ Suppression possible + affichage clair par date
// -------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore/slot_service.dart';

class PartnerSlotsCalendar extends StatefulWidget {
  final String partnerId;

  const PartnerSlotsCalendar({super.key, required this.partnerId});

  @override
  State<PartnerSlotsCalendar> createState() => _PartnerSlotsCalendarState();
}

class _PartnerSlotsCalendarState extends State<PartnerSlotsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _slotsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await SlotService.getExpandedPartnerSlots(widget.partnerId);

    final map = <DateTime, List<Map<String, dynamic>>>{};
    for (final slot in slots) {
      final date = (slot['startTime'] as Timestamp).toDate();
      final key = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(key, () => []).add(slot);
    }

    setState(() => _slotsByDay = map);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _slotsByDay[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onSlotTap(Map<String, dynamic> slot) {
    final dt = (slot['startTime'] as Timestamp).toDate();
    final reductions = List<Map<String, dynamic>>.from(
      slot['reductions'] ?? [],
    );

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
                ...reductions.map(
                  (r) => Text(
                    'Réduction : -${r['amount']}% dès ${r['groupSize']} personnes',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: implémenter la modification
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await SlotService.deleteSlot(
                          widget.partnerId,
                          slot['id'],
                        );
                        Navigator.pop(context);
                        _loadSlots();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            locale: 'fr_FR',
            focusedDay: _focusedDay,
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(markerSize: 6),
          ),
          const SizedBox(height: 12),
          if (_selectedDay != null &&
              _getEventsForDay(_selectedDay!).isNotEmpty)
            ..._getEventsForDay(_selectedDay!).map(
              (slot) => ListTile(
                title: Text(
                  DateFormat(
                    'HH:mm',
                  ).format((slot['startTime'] as Timestamp).toDate()),
                ),
                subtitle: Text('${slot['reductions'].length} réduction(s)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _onSlotTap(slot),
              ),
            ),
        ],
      ),
    );
  }
}
