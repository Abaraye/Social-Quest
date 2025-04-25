import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/quest.dart';
import 'package:mvp_social_quest/services/firestore/quest_service.dart';

class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Quest>>(
      stream: QuestService.instance.streamAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final quests = snapshot.data ?? [];
        if (quests.isEmpty) {
          return const Center(child: Text('Aucune quête disponible.'));
        }
        return ListView.builder(
          itemCount: quests.length,
          itemBuilder: (_, i) {
            final q = quests[i];
            return ListTile(
              leading:
                  q.photos.isNotEmpty
                      ? Image.network(
                        q.photos.first,
                        width: 56,
                        fit: BoxFit.cover,
                      )
                      : const Icon(Icons.flag_outlined),
              title: Text(q.title),
              subtitle: Text('${q.priceCents / 100} ${q.currency}'),
              onTap: () {
                // 👉 navigation vers page détail (à venir)
              },
            );
          },
        );
      },
    );
  }
}
