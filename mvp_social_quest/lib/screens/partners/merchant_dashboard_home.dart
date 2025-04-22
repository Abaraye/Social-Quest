// =============================================================
// lib/screens/partners/merchant_dashboard_home.dart – v2.5
// =============================================================
// 🏠 Point d'entrée commerçant après login
// ✅ Affiche le Dashboard ou un message si aucune activité
// ➕ Bouton « créer activité » (leading)
// 🔄 Switch de partenaire intégré à l’AppBar si activités
// 🗓️ Calendrier masqué par défaut, affiché sur action
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore/stats_service.dart';
import 'merchant_dashboard_page.dart';
import 'manage_partner_page.dart';
import '../../widgets/partners/dashboard/mini_calendar.dart';

class MerchantDashboardHome extends StatefulWidget {
  const MerchantDashboardHome({super.key});

  @override
  State<MerchantDashboardHome> createState() => _MerchantDashboardHomeState();
}

class _MerchantDashboardHomeState extends State<MerchantDashboardHome> {
  String? selectedPartnerId;
  bool showCalendar = false;

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
          debugPrint('📋 Firestore error: \${partnerSnap.error}');
          return const Scaffold(
            body: Center(child: Text('Erreur Firestore.\nVoir console.')),
          );
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
            leading: IconButton(
              icon: const Icon(Icons.add_business),
              tooltip: 'Créer une activité',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagePartnerPage()),
                );
              },
            ),
            actions: [
              if (hasActivities)
                PopupMenuButton<String?>(
                  onSelected: (id) => setState(() => selectedPartnerId = id),
                  icon: const Icon(Icons.switch_account),
                  itemBuilder:
                      (ctx) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('Vue globale'),
                        ),
                        ...partners.map(
                          (p) => PopupMenuItem(
                            value: p['id'],
                            child: Text(p['name'] ?? ''),
                          ),
                        ),
                      ],
                ),
            ],
          ),
          body:
              !hasActivities
                  ? const Center(
                    child: Text(
                      'Crée une activité pour voir les statistiques.',
                    ),
                  )
                  : FutureBuilder<PartnerStats>(
                    future: StatsService.getPartnerStats(selected!['id']!),
                    builder: (context, statSnap) {
                      if (statSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (statSnap.hasError) {
                        debugPrint('📋 StatsService error: \${statSnap.error}');
                        return const Center(
                          child: Text('Erreur lors du chargement des stats.'),
                        );
                      }

                      final stats = statSnap.data!;
                      return Column(
                        children: [
                          Expanded(
                            child: MerchantDashboardPage(
                              partnerId: selected['id']!,
                              partnerName: selected['name']!,
                              bookingsByDay: stats.bookingsByDay,
                              fillRate: stats.fillRate,
                              avgRating: stats.avgRating,
                              allPartners: partners,
                              onPartnerSelected:
                                  (id) =>
                                      setState(() => selectedPartnerId = id),
                              onShowCalendar:
                                  () => setState(() => showCalendar = true),
                            ),
                          ),
                          if (showCalendar)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: PartnerSlotsCalendar(
                                partnerId: selected['id']!,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
        );
      },
    );
  }
}
