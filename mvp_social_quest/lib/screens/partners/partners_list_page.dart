// lib/screens/partners/partners_list_page.dart

import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/partner.dart';
import 'partner_detail_page.dart';
import '../../../widgets/partner_card.dart';

class PartnersListPage extends StatefulWidget {
  const PartnersListPage({super.key});

  @override
  State<PartnersListPage> createState() => _PartnersListPageState();
}

class _PartnersListPageState extends State<PartnersListPage> {
  List<Partner> allPartners = [];
  List<Partner> favoritePartners = [];

  String selectedSort = 'Par défaut';
  List<String> selectedCategories = [];
  double selectedRadius = 10.0;
  String searchQuery = '';

  Position? currentPosition;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadPartners();
    _loadFavorites();
  }

  Future<void> _loadPartners() async {
    allPartners = [
      Partner(
        id: '1',
        name: 'Escape Game Paris',
        description: 'Un escape game immersif au cœur de Paris.',
        slots: {
          '10:00': ['5% pour 3 pers.'],
          '14:00': ['7% pour 4 pers.'],
        },
        category: 'Jeux',
        latitude: 48.8566,
        longitude: 2.3522,
      ),
      Partner(
        id: '2',
        name: 'Atelier de cuisine',
        description: 'Cuisinez comme un chef avec des produits locaux.',
        slots: {
          '11:00': ['15% pour 2 pers.'],
          '16:00': ['20% pour 4 pers.'],
        },
        category: 'Cuisine',
        latitude: 48.8570,
        longitude: 2.3500,
      ),
      // Ajoute ici les autres partenaires
    ];
    setState(() {});
  }

  Future<void> _loadFavorites() async {
    prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('favorites') ?? [];
    favoritePartners =
        stored.map((e) => Partner.fromJson(json.decode(e))).toList();
    setState(() {});
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

  double _distance(Partner partner) {
    if (currentPosition == null) return 0;
    final lat1 = currentPosition!.latitude;
    final lon1 = currentPosition!.longitude;
    final lat2 = partner.latitude;
    final lon2 = partner.longitude;
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearbyPartners =
        (selectedSort == 'Par distance' && currentPosition != null)
            ? allPartners.where((p) => _distance(p) <= selectedRadius).toList()
            : allPartners;

    List<Partner> visiblePartners =
        nearbyPartners.where((p) {
          final matchSearch = p.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          final matchCategory =
              selectedCategories.isEmpty ||
              selectedCategories.contains(p.category);
          return matchSearch && matchCategory;
        }).toList();

    if (selectedSort == 'Par nom') {
      visiblePartners.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSort == 'Par réduction') {
      visiblePartners.sort((a, b) => b.maxReduction.compareTo(a.maxReduction));
    } else if (selectedSort == 'Par distance' && currentPosition != null) {
      visiblePartners.sort((a, b) => _distance(a).compareTo(_distance(b)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (_) => ListView(
                      children:
                          favoritePartners
                              .map(
                                (p) => PartnerCard(
                                  partner: p,
                                  isFavorite: true,
                                  onFavoriteToggle: () => _toggleFavorite(p),
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  PartnerDetailPage(partner: p),
                                        ),
                                      ),
                                ),
                              )
                              .toList(),
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedSort == 'Par distance')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Rayon de recherche : ${selectedRadius.toStringAsFixed(1)} km',
                  ),
                  Slider(
                    min: 1,
                    max: 50,
                    value: selectedRadius,
                    label: '${selectedRadius.toStringAsFixed(1)} km',
                    onChanged:
                        (value) => setState(() => selectedRadius = value),
                  ),
                ],
              ),
            ),
          DropdownButton<String>(
            value: selectedSort,
            items:
                ['Par défaut', 'Par nom', 'Par réduction', 'Par distance']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (val) async {
              setState(() => selectedSort = val!);
              if (val == 'Par distance') await _getCurrentLocation();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: visiblePartners.length,
              itemBuilder:
                  (context, i) => PartnerCard(
                    partner: visiblePartners[i],
                    isFavorite: isFavorite(visiblePartners[i]),
                    onFavoriteToggle: () => _toggleFavorite(visiblePartners[i]),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PartnerDetailPage(
                                  partner: visiblePartners[i],
                                ),
                          ),
                        ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
