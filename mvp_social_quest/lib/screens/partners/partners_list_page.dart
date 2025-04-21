// =============================================================
// lib/screens/partners/partners_list_page.dart  – v3.1
// =============================================================
// Correctif : tri par réduction (du + fort  ➜  + faible)
//  • compareTo inversé  (b vs a)  ⇒  (a, b) => b.maxReductionDisplay - a.max …
//  • Tri par nom inchangé
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/partner.dart';
import 'package:mvp_social_quest/screens/partners/partner_detail_page.dart';
import 'package:mvp_social_quest/services/firestore/partner_service.dart';
import 'package:mvp_social_quest/services/firestore/favorites_service.dart';
import '../../widgets/partners/partner_card.dart';

class PartnersListPage extends StatefulWidget {
  const PartnersListPage({super.key});

  @override
  State<PartnersListPage> createState() => _PartnersListPageState();
}

class _PartnersListPageState extends State<PartnersListPage> {
  String searchQuery = '';
  Set<String> selectedCategories = {}; // multi‑sélection
  String sortBy = 'nom';

  bool _isCatSelected(String c) => selectedCategories.contains(c);

  void _toggleCategory(String cat) {
    setState(() {
      if (cat == '__all__') {
        selectedCategories.clear();
      } else {
        if (selectedCategories.contains(cat)) {
          selectedCategories.remove(cat);
        } else {
          selectedCategories.add(cat);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités autour de moi'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // 🔎 BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher une activité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
            ),
          ),
          // 📡 STREAM FAVORIS -> STREAM PARTENAIRES
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

                    // Liste brute
                    var partners = snap.data!;

                    // ---- CATEGORIES DYNAMIQUES ----
                    final cats =
                        partners
                            .map((p) => p.category)
                            .where((c) => c.isNotEmpty)
                            .toSet();

                    // ---- FILTRES ----
                    partners =
                        partners.where((p) {
                          final matchQuery = p.name.toLowerCase().contains(
                            searchQuery,
                          );
                          final matchCat =
                              selectedCategories.isEmpty ||
                              selectedCategories.contains(p.category);
                          return matchQuery && matchCat;
                        }).toList();

                    // ---- TRI ----
                    if (sortBy == 'nom') {
                      partners.sort((a, b) => a.name.compareTo(b.name));
                    } else if (sortBy == 'reduction') {
                      // du plus GRAND pourcentage vers le plus petit
                      partners.sort(
                        (a, b) => b.maxReductionDisplay.compareTo(
                          a.maxReductionDisplay,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // ----- ROW CATEGORIES -----
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Tous'),
                                selected: selectedCategories.isEmpty,
                                onSelected: (_) => _toggleCategory('__all__'),
                              ),
                              const SizedBox(width: 8),
                              ...cats.map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: _isCatSelected(cat),
                                    onSelected: (_) => _toggleCategory(cat),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ----- DROPDOWN TRI -----
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DropdownButtonFormField<String>(
                            value: sortBy,
                            decoration: const InputDecoration(
                              labelText: 'Trier par',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'nom',
                                child: Text('Nom'),
                              ),
                              DropdownMenuItem(
                                value: 'reduction',
                                child: Text('Réduction'),
                              ),
                              // DropdownMenuItem(value: 'distance', child: Text('Distance')), // TODO: geo
                            ],
                            onChanged:
                                (v) => setState(() => sortBy = v ?? 'nom'),
                          ),
                        ),
                        // ----- LISTE PARTNERS -----
                        Expanded(
                          child: ListView.builder(
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
                                  await FavoritesService.toggleFavorite(
                                    partner.id,
                                  );
                                  final action =
                                      isFav
                                          ? 'retiré des favoris'
                                          : 'ajouté aux favoris';
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${partner.name} $action',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PartnerDetailPage(
                                            partner: partner,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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
