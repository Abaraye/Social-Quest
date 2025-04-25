// lib/screens/bookings/my_bookings_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final q =
        FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: q,
        builder: (_, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('Aucune réservation'));
          return ListView(
            children:
                docs.map((d) {
                  return ListTile(
                    title: Text(d['questTitle'] ?? 'Activité'),
                    subtitle: Text('Statut : ${d['status']}'),
                    onTap: () => context.go('/quest/${d['questId']}'),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
