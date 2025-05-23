import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/core/providers/partner_provider.dart';
import 'package:mvp_social_quest/core/state/partner_controller.dart';
import 'package:mvp_social_quest/core/state/quest_controller.dart';
import 'package:mvp_social_quest/widgets/common/async_value_widget.dart';

class PartnerDashboardPage extends ConsumerWidget {
  final String partnerId;
  const PartnerDashboardPage({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partners = ref.watch(partnerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard commerçant')),
      body: AsyncValueWidget(
        value: partners,
        dataBuilder:
            (list) =>
                list.isEmpty
                    ? const Center(child: Text('Aucun commerce enregistré.'))
                    : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final p = list[i];
                        final quests = ref.watch(questsOfPartnerProvider(p.id));

                        return Card(
                          margin: const EdgeInsets.all(12),
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Modifier ce commerce',
                                      onPressed: () {
                                        context.push(
                                          '/dashboard/partner/${p.id}/edit',
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      tooltip: 'Nouvelle activité',
                                      onPressed: () {
                                        context.push(
                                          '/dashboard/${p.id}/quest/new',
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Supprimer',
                                      onPressed:
                                          () => showDialog<bool>(
                                            context: context,
                                            builder:
                                                (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Supprimer ce commerce ?',
                                                  ),
                                                  content: const Text(
                                                    'Toutes les activités, créneaux et réductions associées seront également supprimées.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => context.pop(
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Annuler',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Suppression en cascade : partner  ses quests  leurs slots & réductions
                                                        ref
                                                            .read(
                                                              partnerControllerProvider
                                                                  .notifier,
                                                            )
                                                            .deleteCascade(
                                                              p.id,
                                                            );
                                                        context.pop(true);
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Supprimer',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            children: [
                              AsyncValueWidget(
                                value: quests,
                                dataBuilder:
                                    (qs) => Column(
                                      children:
                                          qs
                                              .map(
                                                (q) => ListTile(
                                                  title: Text(q.title),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .calendar_today_outlined,
                                                        ),
                                                        tooltip:
                                                            'Voir le calendrier',
                                                        onPressed: () {
                                                          context.push(
                                                            '/dashboard/$partnerId/quest/${q.id}/slots',
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                        ),
                                                        tooltip: 'Modifier',
                                                        onPressed: () {
                                                          context.push(
                                                            '/dashboard/$partnerId/quest/${q.id}/edit',
                                                            extra: q,
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                        ),
                                                        tooltip: 'Supprimer',
                                                        onPressed:
                                                            () => showDialog<
                                                              bool
                                                            >(
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    ctx,
                                                                  ) => AlertDialog(
                                                                    title: const Text(
                                                                      'Supprimer cette activité ?',
                                                                    ),
                                                                    content:
                                                                        const Text(
                                                                          'Cette action est irréversible.',
                                                                        ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              ctx,
                                                                            ),
                                                                        child: const Text(
                                                                          'Annuler',
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          // Appel en cascade : supprime la quest  ses slots & réductions
                                                                          ref
                                                                              .read(
                                                                                questControllerProvider.notifier,
                                                                              )
                                                                              .deleteCascade(
                                                                                partnerId:
                                                                                    p.id,
                                                                                questId:
                                                                                    q.id,
                                                                              );
                                                                          Navigator.pop(
                                                                            ctx,
                                                                          );
                                                                        },

                                                                        child: const Text(
                                                                          'Supprimer',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouveau commerce',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => context.go('/dashboard/partner/new'),
      ),
    );
  }
}
