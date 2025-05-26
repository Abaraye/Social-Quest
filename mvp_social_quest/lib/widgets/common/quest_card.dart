import 'package:flutter/material.dart';
import '../../../models/quest.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const QuestCard({
    required this.quest,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (quest.photos.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: quest.photos.length,
                        itemBuilder:
                            (_, index) => Image.network(
                              quest.photos[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('${quest.priceCents / 100} ${quest.currency}'),
                    ],
                  ),
                ),
              ],
            ),

            // ❤️ Bouton favori en haut à droite
            if (onFavoriteToggle != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
