import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/utils/validators.dart'; // 🆕
import '../../../models/reduction.dart';
import '../../../models/slot.dart';
import '../../../services/firestore/slot_service.dart';

/// Mode d'utilisation du calendrier :
/// - view   : lecture seule (onSlotTap peut ouvrir un détail / réservation)
/// - manage : gestion (ajout / suppression / édition de créneaux)
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
  bool _showOnlyFree = false;

  static const int _defaultPriceCents = 2000; // 20 €

  @override
  void initState() {
    super.initState();
    _loadAndGroupSlots();
  }

  Future<void> _loadAndGroupSlots() async {
    final raw = await SlotService.getExpandedSlots(widget.partnerId);
    final map = <DateTime, List<Slot>>{};
    for (final slot in raw) {
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
    final all = _slotsByDay[key] ?? [];
    if (widget.mode == SlotsCalendarMode.manage && _showOnlyFree) {
      return all.where((s) => !s.reserved).toList();
    }
    return all;
  }

  // ───────────────────────────── Ajout rapide d’un créneau simple
  Future<void> _addQuickSlot() async {
    if (_selectedDay == null) return;

    // 1. Demande l’heure
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (time == null) return;

    // 2. Demande le prix TTC (€) – validated by FormValidators.priceRange
    final priceEuros = await _askPriceDialog();
    if (priceEuros == null) return;
    final priceCents = (priceEuros * 100).round();

    final start = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      time.hour,
      time.minute,
    );

    final slot = Slot(
      id: '',
      startTime: start,
      duration: 60,
      priceCents: priceCents,
      currency: 'EUR',
      reductions: const <Reduction>[],
      reserved: false,
    );

    await SlotService.addSlot(widget.partnerId, slot);
    await _loadAndGroupSlots();
    widget.onSlotAdded?.call();
  }

  Future<double?> _askPriceDialog() async {
    final ctrl = TextEditingController(
      text: (_defaultPriceCents / 100).toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    final res = await showDialog<double>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Prix TTC (€)'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(suffixText: '€'),
                validator: FormValidators.priceRange(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      double.parse(ctrl.text.replaceAll(',', '.')),
                    );
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
    return res;
  }

  // ──────────────────────────────────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Slot>(
          locale: 'fr_FR',
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate:
              (d) => _selectedDay != null && isSameDay(d, _selectedDay),
          onDaySelected: (sel, foc) {
            setState(() {
              _selectedDay = isSameDay(sel, _selectedDay) ? null : sel;
              _focusedDay = foc;
            });
          },
          eventLoader: _eventsForDay,
          calendarStyle: const CalendarStyle(markerSize: 6),
        ),

        if (widget.mode == SlotsCalendarMode.manage &&
            _selectedDay != null) ...[
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Afficher seulement disponibles'),
            value: _showOnlyFree,
            onChanged: (v) => setState(() => _showOnlyFree = v),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter créneau rapide'),
            onPressed: _addQuickSlot,
          ),
        ],

        if (_selectedDay != null) ...[
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _eventsForDay(_selectedDay!).length,
              itemBuilder: (_, i) {
                final slot = _eventsForDay(_selectedDay!)[i];
                final time = DateFormat.Hm().format(slot.startTime);
                return Card(
                  color: slot.reserved ? Colors.grey.shade200 : Colors.white,
                  child: ListTile(
                    title: Text(time),
                    subtitle: Text(
                      '${slot.priceCents / 100} € • '
                      '${slot.reductions.length} réduction(s)',
                    ),
                    trailing:
                        widget.mode == SlotsCalendarMode.manage
                            ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _handleDelete(slot);
                                await _loadAndGroupSlots();
                                widget.onSlotAdded?.call();
                              },
                            )
                            : null,
                    onTap: () => widget.onSlotTap?.call(slot),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleDelete(Slot slot) async {
    if (slot.recurrenceGroupId != null) {
      final choice = await showDialog<String>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Supprimer le créneau'),
              content: const Text(
                'Supprimer cette occurrence ou toute la série ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'one'),
                  child: const Text('Cette occurrence'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'all'),
                  child: const Text('Toute la série'),
                ),
              ],
            ),
      );
      if (choice == 'one') {
        await SlotService.deleteSingleOccurrence(
          widget.partnerId,
          slot.id,
          slot.startTime,
        );
      } else if (choice == 'all') {
        await SlotService.deleteRecurrenceGroup(
          widget.partnerId,
          slot.recurrenceGroupId!,
        );
      }
    } else {
      await SlotService.updateSlot(
        partnerId: widget.partnerId,
        slotId: slot.id,
        updates: {'reserved': true},
      );
    }
  }
}
