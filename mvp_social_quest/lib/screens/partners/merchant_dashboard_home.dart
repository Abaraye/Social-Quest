import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore/stats_service.dart';
import 'merchant_dashboard_page.dart';

/// ✨ Widget branché à l’onglet « Dashboard » dans la BottomNavigationBar.
/// Affiche les statistiques consolidées ou d'une activité précise.
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
          return const Center(child: CircularProgressIndicator());
        }

        if (partnerSnap.hasError) {
          debugPrint('📛 Firestore error: ${partnerSnap.error}');
          return const Center(
            child: Text('Erreur Firestore.\nDétail visible dans la console.'),
          );
        }

        final docs = partnerSnap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('Crée une activité pour voir les statistiques.'),
          );
        }

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
                : partners.first;

        return FutureBuilder<PartnerStats>(
          future: StatsService.getPartnerStats(selected['id']!),
          builder: (context, statSnap) {
            if (statSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (statSnap.hasError) {
              debugPrint('📛 StatsService error: ${statSnap.error}');
              return const Center(
                child: Text('Erreur lors du chargement des stats.'),
              );
            }

            final stats = statSnap.data!;
            return MerchantDashboardPage(
              partnerId: selected['id']!,
              partnerName: selected['name']!,
              bookingsByDay: stats.bookingsByDay,
              fillRate: stats.fillRate,
              avgRating: stats.avgRating,
              allPartners: partners, // ✅ Correction ici
              onPartnerSelected:
                  (id) => setState(() {
                    selectedPartnerId = id;
                  }),
            );
          },
        );
      },
    );
  }
}
