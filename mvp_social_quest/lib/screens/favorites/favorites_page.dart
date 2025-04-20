import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/partner.dart';
import '../partners/partner_detail_page.dart';
import '../../widgets/partner_card.dart';

/// Écran affichant les partenaires ajoutés aux favoris (via SharedPreferences).
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Partner> favoritePartners = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Chargement au démarrage
  }

  /// Charge les partenaires favoris depuis SharedPreferences
  Future<void> _loadFavorites() async {
    prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoritePartners =
          stored.map((jsonString) {
            final data = json.decode(jsonString);
            return Partner.fromJson(data);
          }).toList();
    });
  }

  /// Ajoute ou supprime un partenaire des favoris
  Future<void> _toggleFavorite(Partner partner) async {
    setState(() {
      if (favoritePartners.contains(partner)) {
        favoritePartners.remove(partner);
      } else {
        favoritePartners.add(partner);
      }
    });

    // Mise à jour locale de SharedPreferences
    final updatedList =
        favoritePartners.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList('favorites', updatedList);
  }

  /// Vérifie si un partenaire est déjà en favoris
  bool isFavorite(Partner partner) {
    return favoritePartners.contains(partner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          favoritePartners.isEmpty
              ? const Center(
                child: Text(
                  'Vous n’avez encore aucun favori 💖',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: favoritePartners.length,
                itemBuilder: (context, i) {
                  final partner = favoritePartners[i];
                  return PartnerCard(
                    partner: partner,
                    isFavorite: true,
                    onFavoriteToggle: () => _toggleFavorite(partner),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartnerDetailPage(partner: partner),
                          ),
                        ),
                  );
                },
              ),
    );
  }
}
