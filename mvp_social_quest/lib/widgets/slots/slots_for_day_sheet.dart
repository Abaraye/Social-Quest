// lib/widgets/slots/slots_for_day_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mvp_social_quest/core/providers/partner_provider.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';
import 'package:mvp_social_quest/core/providers/slot_provider.dart';
import 'package:mvp_social_quest/models/slot.dart';
import 'package:mvp_social_quest/widgets/forms/slot_form.dart';

class SlotsForDaySheet extends ConsumerWidget {
  final DateTime date;
  final String partnerId;
  final String questId;

  const SlotsForDaySheet({
    super.key,
    required this.date,
    required this.partnerId,
    required this.questId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ① on récupère la liste live
    final asyncSlots = ref.watch(slotsOfQuestProvider(questId));

    return asyncSlots.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (slots) {
        final df = DateFormat('EEEE d MMMM', 'fr_FR');
        // ② on filtre seulement les slots du jour
        final slotsOfDay =
            slots
                .where(
                  (s) =>
                      s.startTime.year == date.year &&
                      s.startTime.month == date.month &&
                      s.startTime.day == date.day,
                )
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Créneaux du ${df.format(date)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              if (slotsOfDay.isEmpty) const Text('Aucun créneau ce jour.'),

              for (final slot in slotsOfDay)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    '${DateFormat.Hm().format(slot.startTime)} – ${DateFormat.Hm().format(slot.endTime)}',
                  ),
                  subtitle: Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: [
                      Text('Places : ${slot.capacity}'),
                      if (slot.discountCount > 0)
                        const Icon(Icons.local_offer, size: 16),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❌ plus de context.pop() !
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (_) => FractionallySizedBox(
                                  heightFactor: 0.85,
                                  child: SlotForm(
                                    initialDate: date,
                                    questId: questId,
                                    slotToEdit: slot,
                                  ),
                                ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Supprimer ce créneau ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => context.pop(true),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await ref.read(slotRepoProvider).delete(slot.id);
                            // on ne ferme pas la sheet : elle va se rebuild automatiquement
                          }
                        },
                      ),
                    ],
                  ),
                ),

              const Divider(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder:
                        (_) => FractionallySizedBox(
                          heightFactor: 0.85,
                          child: SlotForm(initialDate: date, questId: questId),
                        ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau créneau'),
              ),
            ],
          ),
        );
      },
    );
  }
}
