// lib/screens/partners/partners_list_page.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/partner.dart';
import 'package:mvp_social_quest/screens/partners/create_partner_page.dart';
import 'package:mvp_social_quest/services/firestore_service.dart';
import 'partner_detail_page.dart';
import '../../widgets/partner_card.dart';

class PartnersListPage extends StatelessWidget {
  const PartnersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités autour de moi'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Partner>>(
        stream: FirestoreService.getPartners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune activité trouvée."));
          }

          final partners = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: partners.length,
            itemBuilder: (context, index) {
              final partner = partners[index];
              return PartnerCard(
                partner: partner,
                isFavorite:
                    false, // à remplacer plus tard par de la logique utilisateur
                onFavoriteToggle: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${partner.name} ajouté aux favoris"),
                    ),
                  );
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartnerDetailPage(partner: partner),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
