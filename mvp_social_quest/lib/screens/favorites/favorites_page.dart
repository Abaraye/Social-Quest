import 'package:flutter/material.dart';
import 'package:mvp_social_quest/screens/partners/partner_detail_page.dart';
import 'package:mvp_social_quest/services/firestore/favorites_service.dart';
import 'package:mvp_social_quest/widgets/partners/partner_card.dart';
import 'package:mvp_social_quest/models/partner/partner.dart';

/// 📑 Page affichant la liste des partenaires favoris de l’utilisateur.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Partner>>(
        stream: FavoritesService.favoritePartnersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'Vous n’avez encore aucun favori 💖',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final partner = favorites[index];
              // On utilise directement les getters du modèle Partner
              final id = partner.id;
              final name = partner.name;
              return PartnerCard(
                partner: partner,
                isFavorite: true,
                onFavoriteToggle: () {
                  FavoritesService.toggleFavorite(id);
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
