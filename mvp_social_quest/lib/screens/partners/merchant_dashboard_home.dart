import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/firestore/stats_service.dart';
import 'merchant_dashboard_page.dart';
import 'manage_partner_page.dart';

class MerchantDashboardHome extends StatefulWidget {
  final String partnerId;
  const MerchantDashboardHome({Key? key, required this.partnerId})
    : super(key: key);

  @override
  State<MerchantDashboardHome> createState() => _MerchantDashboardHomeState();
}

class _MerchantDashboardHomeState extends State<MerchantDashboardHome> {
  String? selectedPartnerId;

  @override
  void initState() {
    super.initState();
    // on démarre sur celui passé en paramètre
    selectedPartnerId = widget.partnerId;
  }

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
        final partners = [
          for (final d in docs)
            {'id': d.id, 'name': (d['name'] ?? '(Sans nom)').toString()},
        ];

        // si on a un sélectionné invalide, on retombe sur le premier
        final selected = partners.firstWhere(
          (p) => p['id'] == selectedPartnerId,
          orElse: () => partners.first,
        );

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
                      // utilise GoRouter pour naviguer
                      context.go('/dashboard/${selected['id']!}/quest/new');
                      break;
                    case 'switch':
                      _showPartnerSwitchDialog(partners);
                      break;
                  }
                },
                itemBuilder:
                    (_) => const [
                      PopupMenuItem(
                        value: 'new',
                        child: Text("Créer une activité"),
                      ),
                      PopupMenuItem(
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
                    child: Text("Créez une activité pour voir les stats."),
                  )
                  : FutureBuilder<PartnerStats>(
                    future: StatsService.getPartnerStats(selected['id']!),
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
          (dialogContext) => AlertDialog(
            title: const Text('Changer d’activité'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  partners.map((p) {
                    return ListTile(
                      title: Text(p['name']!),
                      onTap: () {
                        setState(() => selectedPartnerId = p['id']);
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }
}
