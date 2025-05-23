import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/quest_controller.dart';
import '../../core/providers/repository_providers.dart';
import '../../models/quest.dart';
import '../../widgets/forms/quest_form.dart';

class QuestFormPage extends ConsumerWidget {
  final String partnerId;
  final Quest? existing;

  const QuestFormPage({super.key, required this.partnerId, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = ref.watch(questControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'Nouvelle quête' : 'Modifier la quête'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: QuestForm(
          initial: existing,
          onSubmit: (quest) async {
            final ctrl = ref.read(questControllerProvider.notifier);

            final q = quest.copyWith(
              partnerId: partnerId,
              id:
                  existing?.id ??
                  ref.read(questRepoProvider).collection().doc().id,
              createdAt: existing?.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );

            await ctrl.save(q);

            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
