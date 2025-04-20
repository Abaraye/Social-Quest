// lib/widgets/partners/manage/header.dart
import 'package:flutter/material.dart';

class ManagePartnerHeader extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final List<String> categories;
  final void Function(String?) onCategoryChanged;
  final VoidCallback onCreate;

  const ManagePartnerHeader({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Créer une nouvelle activité",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Nom de l'activité"),
            validator: (value) => value!.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            validator: (value) => value!.isEmpty ? "Champ requis" : null,
          ),
          const SizedBox(height: 12),
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
          ElevatedButton.icon(
            icon: const Icon(Icons.add_business),
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size.fromHeight(50),
            ),
            label: const Text("Créer l'activité"),
          ),
        ],
      ),
    );
  }
}
