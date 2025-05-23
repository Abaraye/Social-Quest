import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/core/providers/partner_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/providers/slot_provider.dart';
import '../../../models/slot.dart';
import '../../../widgets/common/async_value_widget.dart';
import '../../../widgets/slots/slots_for_day_sheet.dart';

class PartnerSlotsCalendarPage extends ConsumerStatefulWidget {
  final String partnerId;
  final String questId;

  const PartnerSlotsCalendarPage({
    super.key,
    required this.partnerId,
    required this.questId,
  });

  @override
  ConsumerState<PartnerSlotsCalendarPage> createState() =>
      _PartnerSlotsCalendarPageState();
}

class _PartnerSlotsCalendarPageState
    extends ConsumerState<PartnerSlotsCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final asyncSlots = ref.watch(slotsOfQuestProvider(widget.questId));

    return Scaffold(
      appBar: AppBar(title: const Text('Créneaux & Réductions')),
      body: AsyncValueWidget(
        value: asyncSlots,
        dataBuilder: (slots) {
          final byDay = <DateTime, List<Slot>>{};
          for (final s in slots) {
            final day = DateTime(
              s.startTime.year,
              s.startTime.month,
              s.startTime.day,
            );
            byDay.putIfAbsent(day, () => []).add(s);
          }

          return TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 60)),
            lastDay: DateTime.now().add(const Duration(days: 180)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (rawSelected, focused) {
              final selected = DateTime(
                rawSelected.year,
                rawSelected.month,
                rawSelected.day,
              );
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });

              // on repart de la liste brute et on filtre avec isSameDay
              final daySlots =
                  slots.where((s) => isSameDay(s.startTime, selected)).toList();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder:
                    (_) => SlotsForDaySheet(
                      date: selected,
                      partnerId: widget.partnerId,
                      questId: widget.questId,
                    ),
              );
            },

            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
