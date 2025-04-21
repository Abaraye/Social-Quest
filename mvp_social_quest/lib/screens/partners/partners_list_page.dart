// =============================================================
// lib/screens/partners/partners_list_page.dart (version refactor)
// =============================================================
import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/partner.dart';
import 'package:mvp_social_quest/screens/partners/partner_detail_page.dart';
import 'package:mvp_social_quest/services/firestore/partner_service.dart';
import 'package:mvp_social_quest/services/firestore/favorites_service.dart';
import '../../widgets/partner_card.dart';

class PartnersListPage extends StatefulWidget {
  const PartnersListPage({super.key});
  @override
  State<PartnersListPage> createState() => _PartnersListPageState();
}

class _PartnersListPageState extends State<PartnersListPage> {
  String searchQuery = '';
  String selectedCategory = '';
  String sortBy = 'nom';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités autour de moi'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // 🔎 Recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher une activité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),
          // 🔖 Catégories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: selectedCategory == '',
                  onSelected: (_) => setState(() => selectedCategory = ''),
                ),
                const SizedBox(width: 8),
                for (final cat in ['Sport', 'Jeux', 'Culture', 'Détente'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    ),
                  ),
              ],
            ),
          ),
          // 🔃 Tri
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: sortBy,
              decoration: const InputDecoration(
                labelText: 'Trier par',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'nom', child: Text('Nom')),
                DropdownMenuItem(value: 'reduction', child: Text('Réduction')),
                DropdownMenuItem(value: 'distance', child: Text('Distance')),
              ],
              onChanged: (value) => setState(() => sortBy = value ?? 'nom'),
            ),
          ),
          // 📡 Données
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: FavoritesService.favoriteIdsStream(),
              builder: (context, favSnap) {
                final favIds = favSnap.data ?? [];
                return StreamBuilder<List<Partner>>(
                  stream: PartnerService.getPartners(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snap.hasData || snap.data!.isEmpty) {
                      return const Center(
                        child: Text('Aucune activité trouvée.'),
                      );
                    }
                    var partners = snap.data!;
                    partners =
                        partners.where((p) {
                          final matchQuery = p.name.toLowerCase().contains(
                            searchQuery,
                          );
                          final matchCat =
                              selectedCategory.isEmpty ||
                              p.category == selectedCategory;
                          return matchQuery && matchCat;
                        }).toList();
                    // tri
                    if (sortBy == 'nom') {
                      partners.sort((a, b) => a.name.compareTo(b.name));
                    } else if (sortBy == 'reduction') {
                      partners.sort(
                        (b, a) => a.maxReductionDisplay.compareTo(
                          b.maxReductionDisplay,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: partners.length,
                      itemBuilder: (_, i) {
                        final partner = partners[i];
                        final isFav = FavoritesService.isFavoritedSync(
                          favIds,
                          partner.id,
                        );
                        return PartnerCard(
                          partner: partner,
                          isFavorite: isFav,
                          onFavoriteToggle: () async {
                            await FavoritesService.toggleFavorite(partner.id);
                            final text =
                                isFav
                                    ? 'retiré des favoris'
                                    : 'ajouté aux favoris';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${partner.name} $text')),
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => PartnerDetailPage(partner: partner),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
