// lib/screens/favorites/favorites_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (_, userSnap) {
        if (!userSnap.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final favs = List<String>.from(userSnap.data!['favorites'] ?? []);
        if (favs.isEmpty)
          return const Scaffold(body: Center(child: Text('Aucun favori')));
        final q =
            FirebaseFirestore.instance
                .collection('quests')
                .where(FieldPath.documentId, whereIn: favs)
                .snapshots();
        return Scaffold(
          appBar: AppBar(title: const Text('Favoris')),
          body: StreamBuilder<QuerySnapshot>(
            stream: q,
            builder: (_, snap) {
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              return ListView(
                children:
                    snap.data!.docs.map((d) {
                      return ListTile(
                        title: Text(d['title']),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            favs.remove(d.id);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'favorites': favs});
                          },
                        ),
                        onTap: () => context.go('/quest/${d.id}'),
                      );
                    }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}
