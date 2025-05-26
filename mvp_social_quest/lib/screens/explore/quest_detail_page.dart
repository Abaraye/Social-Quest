import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/widgets/common/async_value_widget.dart';
import 'package:mvp_social_quest/widgets/quest_photo_carousel.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mvp_social_quest/widgets/slots/slots_booking_sheet.dart';

import '../../core/providers/quest_provider.dart';
import '../../core/providers/slot_provider.dart';
import '../../core/providers/user_provider.dart'; // ✅ ajout
import '../../core/providers/service_provider.dart'; // ✅ ajout
import '../../models/slot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/booking_service.dart';

class QuestDetailPage extends ConsumerStatefulWidget {
  final String partnerId;
  final String questId;

  const QuestDetailPage({
    super.key,
    required this.partnerId,
    required this.questId,
  });

  @override
  ConsumerState<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends ConsumerState<QuestDetailPage> {
  String? selectedSlotId;
  int peopleCount = 1;

  @override
  Widget build(BuildContext context) {
    final quest = ref.watch(questProvider(widget.questId));
    final slots = ref.watch(slotListProvider(widget.questId));

    final favValue = ref.watch(favoriteIdsProvider);
    final favIds = favValue.maybeWhen(data: (list) => list, orElse: () => []);

    final isFavorite = favIds.contains(widget.questId);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail activité'),
        actions: [
          if (userId != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () async {
                await ref
                    .read(favoriteServiceProvider)
                    .toggleFavorite(userId, widget.questId, isFavorite);
              },
            ),
        ],
      ),
      body: AsyncValueWidget(
        value: quest,
        dataBuilder: (q) {
          if (q == null)
            return const Center(child: Text("Activité introuvable"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestPhotoCarousel(urls: q.photos),
                const SizedBox(height: 16),
                Text(q.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(q.description),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => SlotBookingSheet(
                                questId: widget.questId,
                                partnerId: widget.partnerId,
                              ),
                        ),
                      );
                    },
                    child: const Text("Réserver"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String questTitle) {
    final slot = ref
        .read(slotListProvider(widget.questId))
        .maybeWhen(
          data: (list) => list.firstWhereOrNull((s) => s.id == selectedSlotId),
          orElse: () => null,
        );

    if (slot == null) return;

    final discountedPrice = slot.priceCents * (1 - slot.discountPercent / 100);
    final total = (discountedPrice * peopleCount / 100).toStringAsFixed(2);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirmation"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Activité : $questTitle'),
                Text('Date : ${slot.formattedDate}'),
                Text('Participants : $peopleCount'),
                Text('Réduction : ${slot.discountPercent}%'),
                Text('Total : $total €'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final bookingService = ref.read(bookingServiceProvider);
                  final userId = FirebaseAuth.instance.currentUser?.uid;

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Vous devez être connecté pour réserver.",
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await bookingService.reserveBooking(
                      userId: userId,
                      partnerId: widget.partnerId,
                      questId: widget.questId,
                      slotId: slot.id,
                      startTime: slot.startTime,
                      peopleCount: peopleCount,
                      priceCentsPerPerson: slot.priceCents,
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Réservation confirmée ✅"),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
                    }
                  }
                },
                child: const Text("Confirmer"),
              ),
            ],
          ),
    );
  }
}
