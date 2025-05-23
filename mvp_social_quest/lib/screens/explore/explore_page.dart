import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/quest_provider.dart';
import '../../widgets/common/async_value_widget.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explorer')),
      body: AsyncValueWidget(
        value: quests,
        dataBuilder:
            (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder:
                  (_, i) => ListTile(
                    title: Text(list[i].title),
                    subtitle: Text(
                      '${list[i].priceCents / 100} ${list[i].currency}',
                    ),
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pushNamed('/quest/${list[i].id}'),
                  ),
            ),
      ),
    );
  }
}
