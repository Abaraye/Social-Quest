import 'package:flutter/material.dart';
import '../models/partner.dart';
import 'common/favorite_button.dart';
import 'common/category_badge.dart';

class PartnerCard extends StatelessWidget {
  final Partner partner;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const PartnerCard({
    super.key,
    required this.partner,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Titre + bouton favori
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      partner.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FavoriteButton(
                    isFavorite: isFavorite,
                    onToggle: onFavoriteToggle,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 🔹 Tags (catégorie + réduction)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  CategoryBadge(category: partner.category),
                  if (partner.maxReductionDisplay > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🔥 Jusqu’à -${partner.maxReductionDisplay}%',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // 🔹 Description
              Text(
                partner.description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
