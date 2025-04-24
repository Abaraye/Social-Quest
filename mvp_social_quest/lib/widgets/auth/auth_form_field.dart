import 'package:flutter/material.dart';

/// Un champ de formulaire personnalisé pour les pages d'authentification.
/// Utilisable pour email, mot de passe ou tout autre champ simple avec validation.
class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? icon; // on réintroduit l’icône

  const AuthFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.icon, // nommé
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) => value == null || value.isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        // si on a une icône, on la met en prefix
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
