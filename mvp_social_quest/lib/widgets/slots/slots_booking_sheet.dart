import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/slot_provider.dart';
import '../../core/providers/service_provider.dart';
import '../../models/slot.dart';

class SlotBookingSheet extends ConsumerStatefulWidget {
  final String questId;
  final String partnerId;

  const SlotBookingSheet({
    super.key,
    required this.questId,
    required this.partnerId,
  });

  @override
  ConsumerState<SlotBookingSheet> createState() => _SlotBookingSheetState();
}

class _SlotBookingSheetState extends ConsumerState<SlotBookingSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Slot? _selectedSlot;
  int peopleCount = 1;
  Map<DateTime, List<Slot>> grouped = {};

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(slotListProvider(widget.questId));

    return Scaffold(
      appBar: AppBar(title: const Text('Réserver un créneau')),
      body: slotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (slots) {
          grouped = _groupSlotsByDate(slots);

          final selectedKey =
              _selectedDay != null
                  ? DateTime.utc(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                  )
                  : null;

          final slotsForSelectedDay =
              selectedKey != null ? grouped[selectedKey] ?? [] : [];

          return Column(
            children: [
              TableCalendar(
                locale: 'fr_FR',
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2026, 12, 31),
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _selectedSlot = null;
                  });
                },
                calendarFormat: CalendarFormat.week,
                eventLoader: (day) {
                  final key = DateTime.utc(day.year, day.month, day.day);
                  return grouped[key] ?? [];
                },
              ),
              const SizedBox(height: 16),
              if (_selectedDay == null)
                const Text("Veuillez sélectionner une date."),
              if (_selectedDay != null && slotsForSelectedDay.isEmpty)
                const Text("Aucun créneau ce jour."),
              if (slotsForSelectedDay.isNotEmpty)
                ...slotsForSelectedDay.map(
                  (slot) => RadioListTile<Slot>(
                    title: Text(DateFormat.Hm('fr_FR').format(slot.startTime)),
                    subtitle: Text('${slot.priceCents / 100} € par personne'),
                    value: slot,
                    groupValue: _selectedSlot,
                    onChanged: (val) => setState(() => _selectedSlot = val),
                  ),
                ),
              const Divider(height: 32),
              if (_selectedSlot != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Participants"),
                          DropdownButton<int>(
                            value: peopleCount,
                            onChanged:
                                (val) => setState(() => peopleCount = val ?? 1),
                            items:
                                List.generate(10, (i) => i + 1)
                                    .map(
                                      (n) => DropdownMenuItem(
                                        value: n,
                                        child: Text("$n"),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getPriceDisplay(_selectedSlot!, peopleCount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _confirmBooking(_selectedSlot!),
                        child: const Text("Confirmer la réservation"),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<Slot>> _groupSlotsByDate(List<Slot> slots) {
    final map = <DateTime, List<Slot>>{};
    for (final slot in slots) {
      final date = DateTime.utc(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      map.putIfAbsent(date, () => []).add(slot);
    }
    return map;
  }

  String _getPriceDisplay(Slot slot, int count) {
    final rawTotal = slot.priceCents * count;
    final hasDiscount = count >= slot.discountCount;
    final total = hasDiscount ? rawTotal * 0.9 : rawTotal.toDouble();
    return "Total : ${total / 100} €" +
        (hasDiscount ? " (10% de réduction)" : "");
  }

  Future<void> _confirmBooking(Slot slot) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final bookingService = ref.read(bookingServiceProvider);

    await bookingService.reserveBooking(
      userId: userId,
      partnerId: widget.partnerId,
      questId: widget.questId,
      slotId: slot.id,
      startTime: slot.startTime,
      peopleCount: peopleCount,
      priceCentsPerPerson: slot.priceCents,
    );

    if (mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Réservation confirmée ✅")));
    }
  }
}
