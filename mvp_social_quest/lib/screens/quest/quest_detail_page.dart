// lib/screens/quest/quest_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QuestDetailPage extends StatelessWidget {
  final String questId;
  const QuestDetailPage({Key? key, required this.questId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questRef = FirebaseFirestore.instance
        .collection('quests')
        .doc(questId);
    return FutureBuilder<DocumentSnapshot>(
      future: questRef.get(),
      builder: (_, snap) {
        if (!snap.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final q = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(q['title'])),
          body: Column(
            children: [
              // Description & photos…
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(q['description']),
              ),
              const Divider(),
              // Liste des slots
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('partners')
                          .doc(q['partnerId'])
                          .collection('slots')
                          .orderBy('startTime')
                          .snapshots(),
                  builder: (_, slotSnap) {
                    if (!slotSnap.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final docs = slotSnap.data!.docs;
                    return ListView(
                      children:
                          docs.map((d) {
                            final dt = (d['startTime'] as Timestamp).toDate();
                            return ListTile(
                              title: Text(DateFormat('dd/MM HH:mm').format(dt)),
                              subtitle: Text('${d['duration']} min'),
                              trailing: ElevatedButton(
                                child: const Text('Réserver'),
                                onPressed: () {
                                  // pass questId & slotId en queryParams
                                  context.go(
                                    '/bookings/new',
                                    extra: {'questId': questId, 'slotId': d.id},
                                  );
                                },
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
