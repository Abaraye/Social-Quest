// widgets/common/delete_button.dart
import 'package:flutter/material.dart';

/// 🗑️ Bouton rouge standard pour actions de suppression
class DeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double borderRadius;

  const DeleteButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
