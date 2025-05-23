import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/quest_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class QuestPage extends ConsumerWidget {
  final String questId;
  const QuestPage({super.key, required this.questId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = ref.watch(questProvider(questId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail quête')),
      body: AsyncValueWidget(
        value: quest,
        dataBuilder:
            (q) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q!.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(q.description),
                  const SizedBox(height: 24),
                  Text('Prix : ${q.priceCents / 100} ${q.currency}'),
                ],
              ),
            ),
      ),
    );
  }
}
