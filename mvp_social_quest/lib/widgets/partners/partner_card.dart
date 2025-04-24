// lib/widgets/partners/partner_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/partner/partner.dart';
import '../common/favorite_button.dart';
import '../common/category_badge.dart';

/// Carte présentant un partenaire avec image, nom, note, badges, etc.
class PartnerCard extends StatelessWidget {
  final Partner partner;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final double? distanceKm;

  const PartnerCard({
    Key? key,
    required this.partner,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
    this.distanceKm,
  }) : super(key: key);

  String _formatDistance() {
    if (distanceKm == null) return '';
    return distanceKm! < 1
        ? '${(distanceKm! * 1000).round()} m'
        : '${distanceKm!.toStringAsFixed(1)} km';
  }

  Widget _buildCover(BuildContext context) {
    final radius = BorderRadius.vertical(top: Radius.circular(16));
    if (partner.photos.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          'assets/images/placeholder.jpg',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return Hero(
      tag: 'partner_cover_${partner.id}',
      child: ClipRRect(
        borderRadius: radius,
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
                child: const Icon(Icons.broken_image, size: 32),
              ),
        ),
      ),
    );
  }

  List<Widget> _buildBadges() {
    final badges = <Widget>[CategoryBadge(category: partner.category)];
    if (partner.maxReductionDisplay > 0) {
      badges.add(
        Chip(
          backgroundColor: Colors.orange.shade100,
          label: Text('–${partner.maxReductionDisplay}%'),
          labelStyle: TextStyle(color: Colors.orange.shade800, fontSize: 12),
        ),
      );
    }
    if (distanceKm != null) {
      badges.add(
        Chip(
          backgroundColor: Colors.blue.shade50,
          label: Text(_formatDistance()),
          labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 12),
        ),
      );
    }
    return badges;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                _buildCover(context),
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
                  // Nom & note
                  Row(
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
                      if (partner.avgRating != null) ...[
                        const SizedBox(width: 8),
                        RatingBarIndicator(
                          rating: partner.avgRating!,
                          itemSize: 16,
                          unratedColor: Colors.grey.shade300,
                          itemBuilder:
                              (_, __) =>
                                  const Icon(Icons.star, color: Colors.amber),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          partner.avgRating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Badges
                  Wrap(spacing: 8, runSpacing: 4, children: _buildBadges()),
                  const SizedBox(height: 8),

                  // Description
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
}
