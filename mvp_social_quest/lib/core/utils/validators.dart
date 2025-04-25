import 'package:flutter/material.dart'; // ← nécessaire pour TimeOfDay

/// 🧪 Validateurs de formulaire simples & réutilisables.
class FormValidators {
  const FormValidators._(); // ⛔️ Singleton stateless

  /// 🔢 Valide un champ requis avec nombre entier dans un intervalle [min]–[max].
  static String? Function(String?) numberInRange({
    required String label,
    required int min,
    required int max,
  }) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label requis';
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null) {
        return '$label invalide';
      }
      if (parsed < min || parsed > max) {
        return '$label doit être entre $min et $max';
      }
      return null;
    };
  }

  /// 💶 Valide un prix TTC en euros (double dans [min]–[max]).
  static String? Function(String?) priceRange({
    double min = 1.0,
    double max = 999.0,
  }) {
    return (value) {
      final cleaned = value?.replaceAll(',', '.') ?? '';
      final price = double.tryParse(cleaned);
      if (price == null) return 'Entrez un prix valide';
      if (price < min || price > max) {
        return 'Le prix doit être entre $min € et $max €';
      }
      return null;
    };
  }

  /// 📅 Valide que l’heure est sélectionnée.
  static String? validateTimeOfDay(TimeOfDay? t, {String label = 'Heure'}) {
    return t == null ? '$label requise' : null;
  }
}
