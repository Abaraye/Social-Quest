// lib/widgets/partners/slots/slots_calendar.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/reduction.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/slot.dart';
import '../../../../services/firestore/slot_service.dart';

enum SlotsCalendarMode { view, manage }

class SlotsCalendar extends StatefulWidget {
  final String partnerId;
  final SlotsCalendarMode mode;
  final void Function(Slot)? onSlotTap;
  final VoidCallback? onSlotAdded;

  const SlotsCalendar({
    Key? key,
    required this.partnerId,
    this.mode = SlotsCalendarMode.view,
    this.onSlotTap,
    this.onSlotAdded,
  }) : super(key: key);

  @override
  State<SlotsCalendar> createState() => _SlotsCalendarState();
}

class _SlotsCalendarState extends State<SlotsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Slot>> _slotsByDay = {};
  bool _showForm = false;
  bool _showOnlyFree = false;
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? _selectedTime;
  int? _reduction;
  int? _groupSize;
  String _recurrenceType = 'Aucune';
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final all = await SlotService.getExpandedPartnerSlots(widget.partnerId);
    final map = <DateTime, List<Slot>>{};
    for (var slot in all) {
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

  List<Slot> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _slotsByDay[key] ?? [];
  }

  void _handleSlotTap(Slot slot) {
    if (widget.mode == SlotsCalendarMode.view) {
      widget.onSlotTap?.call(slot);
      return;
    }
    // ... votre code de bottom sheet pour supprimer/modifier
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _createSlot() async {
    if (_selectedDay == null || _selectedTime == null) return;
    final dt = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final slot = Slot(
      id: '',
      startTime: dt,
      duration: 60,
      reductions: [
        if (_reduction != null && _groupSize != null)
          Reduction(amount: _reduction!, groupSize: _groupSize!),
      ],
      recurrence:
          _recurrenceType != 'Aucune'
              ? {
                'type': _recurrenceType,
                if (_endDate != null) 'endDate': Timestamp.fromDate(_endDate!),
              }
              : null,
    );
    await SlotService.addSlot(widget.partnerId, slot);
    widget.onSlotAdded?.call();
    await _loadSlots();
    setState(() {
      _showForm = false;
      _selectedTime = null;
      _reduction = null;
      _groupSize = null;
      _recurrenceType = 'Aucune';
      _endDate = null;
      _showOnlyFree = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _selectedDay != null ? _eventsForDay(_selectedDay!) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar<Slot>(
          locale: 'fr_FR',
          focusedDay: _focusedDay,
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          selectedDayPredicate:
              (d) => _selectedDay != null && isSameDay(_selectedDay, d),
          onDaySelected:
              (sel, foc) => setState(() {
                if (_selectedDay != null && isSameDay(_selectedDay, sel)) {
                  _selectedDay = null;
                } else {
                  _selectedDay = sel;
                }
                _focusedDay = foc;
                _showForm = false;
                _showOnlyFree = false;
              }),
          eventLoader: _eventsForDay,
          calendarBuilders: CalendarBuilders<Slot>(
            markerBuilder: (context, day, slots) {
              final total = slots.length;
              final reserved = slots.where((e) => e.reserved).length;
              if (total == 0) return null;
              Color dotColor;
              if (reserved == total)
                dotColor = Colors.red;
              else if (reserved > 0)
                dotColor = Colors.orange;
              else
                dotColor = Colors.green;
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          calendarStyle: const CalendarStyle(markerSize: 6),
        ),

        // Filtre “Afficher seulement disponibles”
        if (widget.mode == SlotsCalendarMode.manage &&
            _selectedDay != null) ...[
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Afficher seulement disponibles'),
            value: _showOnlyFree,
            onChanged: (v) => setState(() => _showOnlyFree = v),
          ),
        ],

        // Liste des créneaux sous calendrier
        if (_selectedDay != null && events.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var slot in events)
            if (!(_showOnlyFree && slot.reserved))
              ListTile(
                tileColor:
                    slot.reserved ? Colors.red.shade50 : Colors.green.shade50,
                title: Text(DateFormat('HH:mm').format(slot.startTime)),
                subtitle: Text('${slot.reductions.length} réduction(s)'),
                trailing:
                    widget.mode == SlotsCalendarMode.manage
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _handleSlotTap(slot),
                        )
                        : const Icon(Icons.chevron_right),
                onTap: () => _handleSlotTap(slot),
              ),
        ],
      ],
    );
  }
}
