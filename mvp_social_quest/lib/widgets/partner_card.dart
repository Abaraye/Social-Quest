import 'package:flutter/material.dart';
import '../models/partner.dart';

/// 🔹 Carte UI représentant un partenaire/activité
/// Utilisée dans la liste des partenaires, favoris, etc.
class PartnerCard extends StatelessWidget {
  final Partner partner; // Le modèle de l'activité
  final bool isFavorite; // L'état actuel du favori
  final VoidCallback onFavoriteToggle; // Callback pour gérer le favori
  final VoidCallback onTap; // Callback pour ouvrir les détails

  const PartnerCard({
    super.key,
    required this.partner,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  /// 🎯 Emoji associé à chaque catégorie
  String _categoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'cuisine':
        return '🍳';
      case 'sport':
        return '🚴';
      case 'culture':
        return '🎨';
      case 'jeux':
        return '🎲';
      case 'bien-être':
        return '🧘';
      case 'musique':
        return '🎵';
      case 'détente':
        return '🛀';
      default:
        return '🎯';
    }
  }

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
              // 🔹 Titre et bouton favori
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
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 🔹 Tags (catégorie, réduction...)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // 🏷 Catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_categoryEmoji(partner.category)} ${partner.category}',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // 🔥 Réduction max
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
