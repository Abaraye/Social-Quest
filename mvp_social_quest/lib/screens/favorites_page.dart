// lib/screens/favorites_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/partner.dart';
import 'partners/partner_detail_page.dart';
import '../widgets/partner_card.dart';

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
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoritePartners =
          stored.map((e) => Partner.fromJson(json.decode(e))).toList();
    });
  }

  Future<void> _toggleFavorite(Partner partner) async {
    setState(() {
      if (favoritePartners.contains(partner)) {
        favoritePartners.remove(partner);
      } else {
        favoritePartners.add(partner);
      }
    });
    final favs = favoritePartners.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList('favorites', favs);
  }

  bool isFavorite(Partner partner) => favoritePartners.contains(partner);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
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
                itemBuilder:
                    (context, i) => PartnerCard(
                      partner: favoritePartners[i],
                      isFavorite: true,
                      onFavoriteToggle:
                          () => _toggleFavorite(favoritePartners[i]),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PartnerDetailPage(
                                    partner: favoritePartners[i],
                                  ),
                            ),
                          ),
                    ),
              ),
    );
  }
}
