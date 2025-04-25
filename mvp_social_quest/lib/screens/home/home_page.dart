// lib/screens/home/home_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  String _category = 'Tout';
  bool _checkingMerchant = true;

  @override
  void initState() {
    super.initState();
    // Après le premier frame, on vérifie le rôle + existence de partner
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleMerchantFlow());
  }

  Future<void> _handleMerchantFlow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _checkingMerchant = false);
      return;
    }

    // 1️⃣ Récupère le type depuis Firestore /users/{uid}
    final profileSnap =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final type = profileSnap.data()?['type'] as String?;

    if (type == 'merchant') {
      // 2️⃣ Si merchant, regarde ses partners
      final partnersSnap =
          await FirebaseFirestore.instance
              .collection('partners')
              .where('ownerId', isEqualTo: user.uid)
              .where('active', isEqualTo: true)
              .get();

      if (partnersSnap.docs.isEmpty) {
        // Pas encore de commerce → onboarding
        context.go('/partner-form');
      } else {
        // Commerce existant → dashboard
        final firstId = partnersSnap.docs.first.id;
        context.go('/dashboard/$firstId');
      }
      return;
    }

    // 3️⃣ Pour les autres (ou non connecté), on affiche HomePage normalement
    setState(() => _checkingMerchant = false);
  }

  @override
  Widget build(BuildContext context) {
    // Si on est en train de vérifier le rôle, monte un loader
    if (_checkingMerchant) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Sinon, on affiche la page Explorer habituelle
    Query questsQuery = FirebaseFirestore.instance
        .collection('quests')
        .where('isActive', isEqualTo: true);

    if (_category != 'Tout') {
      questsQuery = questsQuery.where('category', isEqualTo: _category);
    }
    if (_search.isNotEmpty) {
      questsQuery = questsQuery.orderBy('title').startAt([_search]).endAt([
        '$_search\uf8ff',
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Rechercher…',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _search = v.trim()),
        ),
        actions: [
          DropdownButton<String>(
            value: _category,
            underline: const SizedBox(),
            items:
                ['Tout', 'Sport', 'Cuisine', 'Bien-être', 'Aventure']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (c) => setState(() => _category = c!),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: questsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune activité trouvée'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? 'Sans titre';
              final category = data['category'] as String? ?? '—';

              return ListTile(
                title: Text(title),
                subtitle: Text(category),
                onTap: () => context.go('/quest/${doc.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
