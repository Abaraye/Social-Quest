import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/partner.dart';
import 'package:mvp_social_quest/screens/partners/partner_detail_page.dart';
import 'package:mvp_social_quest/services/firestore_service.dart';
import '../../widgets/partner_card.dart';

/// Page affichant la liste des partenaires (activités)
/// avec filtres de recherche, catégories, et tri dynamique.
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
          // 🔎 Barre de recherche
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

          // 🔖 Filtres par catégories
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

          // 🔃 Menu de tri
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
              onChanged: (value) {
                if (value != null) {
                  setState(() => sortBy = value);
                }
              },
            ),
          ),

          // 📡 Données récupérées en temps réel depuis Firestore
          Expanded(
            child: StreamBuilder<List<Partner>>(
              stream: FirestoreService.getPartners(),
              builder: (context, snapshot) {
                // Chargement
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Aucune donnée
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucune activité trouvée."));
                }

                // Liste brute des partenaires
                List<Partner> partners = snapshot.data!;

                // 🔍 Appliquer le filtre de recherche et la catégorie
                partners =
                    partners.where((p) {
                      final matchesQuery = p.name.toLowerCase().contains(
                        searchQuery,
                      );
                      final matchesCategory =
                          selectedCategory.isEmpty ||
                          p.category == selectedCategory;
                      return matchesQuery && matchesCategory;
                    }).toList();

                // 🔃 Appliquer le tri
                if (sortBy == 'nom') {
                  partners.sort((a, b) => a.name.compareTo(b.name));
                } else if (sortBy == 'reduction') {
                  partners.sort(
                    (b, a) =>
                        a.maxReductionDisplay.compareTo(b.maxReductionDisplay),
                  );
                } else if (sortBy == 'distance') {
                  // 👇 À implémenter avec la géolocalisation
                  // partners.sort((a, b) => a.distance.compareTo(b.distance));
                }

                // 🧱 Affichage des PartnerCard
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: partners.length,
                  itemBuilder: (context, index) {
                    final partner = partners[index];
                    return PartnerCard(
                      partner: partner,
                      isFavorite:
                          false, // à connecter avec Firestore ou SharedPreferences
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
          ),
        ],
      ),
    );
  }
}
