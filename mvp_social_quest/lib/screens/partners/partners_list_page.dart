import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/partner/partner.dart';
import 'package:mvp_social_quest/screens/partners/partner_detail_page.dart';
import 'package:mvp_social_quest/services/firestore/partner_service.dart';
import 'package:mvp_social_quest/services/firestore/favorites_service.dart';
import '../../widgets/partners/partner_card.dart';
import '../../widgets/common/filter_bar.dart';
import '../../widgets/common/sort_dropdown.dart';

/// 🌍 Liste des activités autour de moi
/// Recherches, filtres par catégorie, tri et favoris.
class PartnersListPage extends StatefulWidget {
  const PartnersListPage({Key? key}) : super(key: key);

  @override
  State<PartnersListPage> createState() => _PartnersListPageState();
}

class _PartnersListPageState extends State<PartnersListPage> {
  String _searchQuery = '';
  Set<String> _selectedCats = {};
  String _sortBy = 'nom';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activités autour de moi')),
      body: Column(
        children: [
          // barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<String>>(
              stream: FavoritesService.favoriteIdsStream(),
              builder: (ctx, favSnap) {
                final favIds = favSnap.data ?? [];
                return StreamBuilder<List<Partner>>(
                  stream: PartnerService.streamPartners(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = snap.data ?? [];

                    // Catégories dynamiques
                    final cats = all.map((p) => p.category).toSet();

                    // Filtrage texte + catégorie
                    var filtered =
                        all.where((p) {
                          final matchText = p.name.toLowerCase().contains(
                            _searchQuery,
                          );
                          final matchCat =
                              _selectedCats.isEmpty ||
                              _selectedCats.contains(p.category);
                          return matchText && matchCat;
                        }).toList();

                    // Tri
                    if (_sortBy == 'nom') {
                      filtered.sort((a, b) => a.name.compareTo(b.name));
                    } else {
                      filtered.sort(
                        (a, b) => b.maxReductionDisplay.compareTo(
                          a.maxReductionDisplay,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Barres de filtre & tri
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              FilterBar(
                                options: cats.toList()..sort(),
                                selected: _selectedCats,
                                onToggle: (cat) {
                                  setState(() {
                                    if (cat == '__all__') {
                                      _selectedCats.clear();
                                    } else if (!_selectedCats.remove(cat)) {
                                      _selectedCats.add(cat);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              SortDropdown<String>(
                                label: 'Trier par',
                                value: _sortBy,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'nom',
                                    child: Text('Nom'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'reduction',
                                    child: Text('Réduction'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _sortBy = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Liste des partenaires
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: filtered.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final p = filtered[i];
                              final isFav = favIds.contains(p.id);
                              return PartnerCard(
                                partner: p,
                                isFavorite: isFav,
                                onFavoriteToggle: () async {
                                  await FavoritesService.toggleFavorite(p.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFav
                                            ? '${p.name} retiré des favoris'
                                            : '${p.name} ajouté aux favoris',
                                      ),
                                    ),
                                  );
                                },
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                PartnerDetailPage(partner: p),
                                      ),
                                    ),
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
