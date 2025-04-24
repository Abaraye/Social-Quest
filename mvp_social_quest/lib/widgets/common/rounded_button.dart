import 'package:flutter/material.dart';

/// 🎨 Bouton arrondi personnalisable
class RoundedButton extends StatelessWidget {
  /// Callback déclenché lors du clic. Si null, le bouton est désactivé.
  final VoidCallback? onPressed;

  /// Contenu du bouton (texte, loader, icône, etc.).
  final Widget child;

  /// Couleur de fond.
  final Color backgroundColor;

  /// Couleur du texte et des icônes.
  final Color foregroundColor;

  /// Rayon des coins.
  final double borderRadius;

  /// Padding interne.
  final EdgeInsetsGeometry padding;

  const RoundedButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.backgroundColor = Colors.deepPurple,
    this.foregroundColor = Colors.white,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: child,
    );
  }
}
