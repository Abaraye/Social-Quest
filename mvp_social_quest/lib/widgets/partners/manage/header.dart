// ===========================================================
// lib/widgets/partners/manage/header.dart – v2.0
// ===========================================================
// 🎯 Composant réutilisable pour créer / modifier une activité
// 🧠 Affiche dynamiquement le titre et le bouton selon le contexte
// -----------------------------------------------------------

import 'package:flutter/material.dart';

class ManagePartnerHeader extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final List<String> categories;
  final void Function(String?) onCategoryChanged;
  final VoidCallback onCreate;
  final bool isEditing; // 👉 Nouveau paramètre pour adapter le header

  const ManagePartnerHeader({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onCreate,
    this.isEditing = false, // 🔄 Par défaut on considère qu'on est en création
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? "Modifier l'activité" : "Créer une nouvelle activité",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Champ nom
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Nom de l'activité"),
            validator: (value) => value!.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: 12),

          // Champ description
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            validator: (value) => value!.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: 12),

          // Choix de la catégorie
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items:
                categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
            onChanged: onCategoryChanged,
            decoration: const InputDecoration(labelText: "Catégorie"),
          ),
          const SizedBox(height: 16),

          // Bouton de validation
          ElevatedButton.icon(
            icon: Icon(isEditing ? Icons.save : Icons.add_business),
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size.fromHeight(50),
            ),
            label: Text(isEditing ? "Modifier l'activité" : "Créer l'activité"),
          ),
        ],
      ),
    );
  }
}
