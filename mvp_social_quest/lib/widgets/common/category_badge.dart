import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

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
        return '🌿';
      default:
        return '🎯';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_categoryEmoji(category)} $category',
        style: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
