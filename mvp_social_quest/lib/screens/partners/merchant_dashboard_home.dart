// lib/screens/partners/merchant_dashboard_home.dart – v3.0

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore/stats_service.dart';
import 'merchant_dashboard_page.dart';
import 'manage_partner_page.dart';

class MerchantDashboardHome extends StatefulWidget {
  const MerchantDashboardHome({super.key});

  @override
  State<MerchantDashboardHome> createState() => _MerchantDashboardHomeState();
}

class _MerchantDashboardHomeState extends State<MerchantDashboardHome> {
  String? selectedPartnerId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Non connecté'));
    }

    final partnersStream =
        FirebaseFirestore.instance
            .collection('partners')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('createdAt')
            .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: partnersStream,
      builder: (context, partnerSnap) {
        if (partnerSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (partnerSnap.hasError) {
          return const Scaffold(body: Center(child: Text('Erreur Firestore.')));
        }

        final docs = partnerSnap.data?.docs ?? [];
        final hasActivities = docs.isNotEmpty;

        final List<Map<String, String>> partners = [
          for (final d in docs)
            {'id': d.id, 'name': (d['name'] ?? '(Sans nom)').toString()},
        ];

        final selected =
            selectedPartnerId != null
                ? partners.firstWhere(
                  (p) => p['id'] == selectedPartnerId,
                  orElse: () => partners.first,
                )
                : partners.isNotEmpty
                ? partners.first
                : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tableau de bord'),
            backgroundColor: Colors.deepPurple,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'new':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManagePartnerPage(),
                        ),
                      );
                      break;
                    case 'switch':
                      _showPartnerSwitchDialog(partners);
                      break;
                  }
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'new',
                        child: Text("Créer une activité"),
                      ),
                      const PopupMenuItem(
                        value: 'switch',
                        child: Text("Changer d'activité"),
                      ),
                    ],
              ),
            ],
          ),
          body:
              !hasActivities
                  ? const Center(
                    child: Text(
                      "Crée une activité pour voir les statistiques.",
                    ),
                  )
                  : FutureBuilder<PartnerStats>(
                    future: StatsService.getPartnerStats(selected!['id']!),
                    builder: (context, statSnap) {
                      if (statSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (statSnap.hasError) {
                        return const Center(
                          child: Text("Erreur lors du chargement des stats."),
                        );
                      }

                      final stats = statSnap.data!;
                      return MerchantDashboardPage(
                        partnerId: selected['id']!,
                        partnerName: selected['name']!,
                        bookingsByDay: stats.bookingsByDay,
                        fillRate: stats.fillRate,
                        avgRating: stats.avgRating,
                        allPartners: partners,
                        onPartnerSelected:
                            (id) => setState(() => selectedPartnerId = id),
                      );
                    },
                  ),
        );
      },
    );
  }

  void _showPartnerSwitchDialog(List<Map<String, String>> partners) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Changer d’activité'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  partners.map((p) {
                    return ListTile(
                      title: Text(p['name'] ?? ''),
                      onTap: () {
                        setState(() => selectedPartnerId = p['id']);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }
}
