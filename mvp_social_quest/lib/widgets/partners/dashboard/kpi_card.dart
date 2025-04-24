import 'package:flutter/material.dart';

/// Carte d’un indicateur clé (KPI) affichant une icône, une valeur et un libellé.
/// 💡 Suggestions :
///  • Extraire les couleurs et tailles dans un thème ou constantes partagées
///  • Ajouter un paramètre `width` si besoin d’adapter la taille en mode responsive
///  • Gérer un état “loading” pour certaines KPI qui se chargent asynchrone­ment
class KpiCard extends StatelessWidget {
  /// Icône du KPI.
  final IconData icon;

  /// Valeur principale (ex. "42", "75 %").
  final String value;

  /// Libellé court décrivant le KPI.
  final String label;

  /// Callback déclenché au tap (navigation possible).
  final VoidCallback? onTap;

  /// Largeur fixe (si l’on veut plusieurs cartes côte à côte).
  final double width;

  const KpiCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
    this.width = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
