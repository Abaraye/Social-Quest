import 'package:flutter/material.dart';

/// 🌟 Une tuile de stats cliquable (label ➔ valeur ➔ action)
class StatTile {
  /// Label court de la statistique
  final String label;

  /// Valeur à afficher (ex: "42", "75 %").
  final String value;

  /// Action optionnelle quand on tape la tuile.
  final VoidCallback? onTap;

  const StatTile({required this.label, required this.value, this.onTap});
}

/// 📊 Affiche une liste de [StatTile] avec séparateurs et navigation.
class StatsOverview extends StatelessWidget {
  final List<StatTile> stats;
  const StatsOverview({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final tile = stats[index];
        return InkWell(
          onTap: tile.onTap,
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(tile.label)),
              Text(
                tile.value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (tile.onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right, size: 18),
                ),
            ],
          ),
        );
      },
    );
  }
}
