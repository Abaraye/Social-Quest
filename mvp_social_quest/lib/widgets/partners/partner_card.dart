// =============================================================
// lib/widgets/partner_card.dart  – v2  (local placeholder asset)
// =============================================================
// • Si la liste `photos` est vide, on affiche un asset local
//   `assets/images/placeholder.jpg` (à déclarer dans pubspec.yaml)
// • CachedNetworkImage n'est utilisé QUE quand il y a une URL.
//
// Assure‑toi d’importer dans pubspec :
//   flutter:
//     assets:
//       - assets/images/placeholder.jpg
//
// et de placer l’image dans ce dossier à la racine du projet (même niveau
// que pubspec.yaml).
// -------------------------------------------------------------

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp type

import '../../models/partner.dart';
import '../common/favorite_button.dart';
import '../common/category_badge.dart';

class PartnerCard extends StatelessWidget {
  final Partner partner;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final double? distanceKm; // optionnel : distance depuis l'utilisateur

  const PartnerCard({
    super.key,
    required this.partner,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
    this.distanceKm,
  });

  // Helper pour formater la distance "2,3 km".
  String? get _distanceLabel {
    if (distanceKm == null) return null;
    final formatted =
        distanceKm! < 1
            ? "${(distanceKm! * 1000).round()} m"
            : "${distanceKm!.toStringAsFixed(1)} km";
    return formatted;
  }

  // Helper pour trouver le prochain slot futur si dispo.
  String? get _nextSlotLabel {
    final now = DateTime.now();
    final futureSlots = partner.slots.values.expand((e) => e).where((s) {
      final ts = s['startTime'];
      return ts is Timestamp && ts.toDate().isAfter(now);
    });
    if (futureSlots.isEmpty) return null;
    final sorted =
        futureSlots.cast<Map<String, dynamic>>().toList()..sort(
          (a, b) => (a['startTime'] as Timestamp).compareTo(
            b['startTime'] as Timestamp,
          ),
        );
    final nextDate = (sorted.first['startTime'] as Timestamp).toDate();
    return DateFormat('dd/MM HH:mm').format(nextDate);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showPreview(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- Couverture + bouton favori overlay --------
            Stack(
              children: [
                _buildCover(radius),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    isFavorite: isFavorite,
                    onToggle: onFavoriteToggle,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----- Titre + Rating -----
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          partner.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (partner.avgRating != null)
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: partner.avgRating!,
                              itemSize: 16,
                              unratedColor: Colors.grey.shade300,
                              itemBuilder:
                                  (_, __) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              partner.avgRating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ----- Badges -----
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      CategoryBadge(category: partner.category),
                      if (partner.maxReductionDisplay > 0)
                        _discountChip(partner.maxReductionDisplay),
                      if (_distanceLabel != null)
                        _distanceChip(_distanceLabel!),
                      if (_nextSlotLabel != null)
                        _nextSlotChip(_nextSlotLabel!),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ----- Description -----
                  Text(
                    partner.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets helpers ----------
  Widget _buildCover(BorderRadius radius) {
    if (partner.photos.isEmpty) {
      // Asset local comme placeholder (aucune requête réseau)
      return Image.asset(
        'assets/images/placeholder.jpg',
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Hero(
      tag: 'partner_cover_${partner.id}',
      child: CachedNetworkImage(
        imageUrl: partner.photos.first,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (_, __) => Container(height: 160, color: Colors.grey.shade100),
        errorWidget:
            (_, __, ___) => Container(
              height: 160,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image,
                size: 32,
                color: Colors.grey,
              ),
            ),
      ),
    );
  }

  Widget _discountChip(int amount) => Chip(
    backgroundColor: Colors.orange.shade100,
    label: Text('🔥 Jusqu’à -$amount%'),
    labelStyle: TextStyle(color: Colors.orange.shade800, fontSize: 12),
  );

  Widget _distanceChip(String d) => Chip(
    backgroundColor: Colors.blue.shade50,
    label: Text('📍 $d'),
    labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 12),
  );

  Widget _nextSlotChip(String label) => Chip(
    backgroundColor: Colors.purple.shade50,
    label: Text('⏰ $label'),
    labelStyle: TextStyle(color: Colors.purple.shade800, fontSize: 12),
  );

  // Aperçu rapide via bottom‑sheet
  void _showPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(partner.description),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onTap();
                  },
                  child: const Text('Voir la fiche complète'),
                ),
              ],
            ),
          ),
    );
  }
}
