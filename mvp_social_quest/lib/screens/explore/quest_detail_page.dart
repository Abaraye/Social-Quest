import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/quest_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class QuestDetailPage extends ConsumerWidget {
  final String partnerId;
  final String questId;
  const QuestDetailPage({
    super.key,
    required this.partnerId,
    required this.questId,
  });

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
                  const SizedBox(height: 8),
                  Text(q.description),
                ],
              ),
            ),
      ),
    );
  }
}
