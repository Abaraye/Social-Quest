// lib/screens/partners/partner_form_creation_page.dart
// -----------------------------------------------------------------------------
// Page de création de Partner (commerce) pour les marchands n'ayant pas
// encore de commerce associé. Affichée automatiquement si aucun partner
// n'est trouvé pour l'utilisateur marchand.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_social_quest/services/firestore/partner/partner_service.dart';

/// PartnerFormCreationPage
/// ----------------------
/// Formulaire pour renseigner les données essentielles d’un commerce :
/// • nom
/// • description
/// • catégorie
/// • latitude & longitude (pour géolocalisation)
///
/// À la soumission, on crée le Partner via PartnerService, puis on
/// redirige vers le dashboard du nouveau partner.
class PartnerFormCreationPage extends StatefulWidget {
  const PartnerFormCreationPage({super.key});

  @override
  State<PartnerFormCreationPage> createState() =>
      _PartnerFormCreationPageState();
}

class _PartnerFormCreationPageState extends State<PartnerFormCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  /// Méthode appelée à la soumission du formulaire
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      // Récupération des valeurs saisies
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final category = _categoryController.text.trim();
      final latitude = double.parse(_latController.text.trim());
      final longitude = double.parse(_lngController.text.trim());

      // Création du partner dans Firestore
      final partnerId = await PartnerService.createPartner(
        name: name,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
      );

      // Optionnel : création du profil marchand (si non déjà fait)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await PartnerService.createUserProfile(
          userId: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? name,
        );
      }

      // Redirection vers le dashboard du partner créé
      context.go('/dashboard/$partnerId');
    } catch (e) {
      // Affichage d'une erreur en cas d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du commerce : \$e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer votre commerce')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pour commencer, renseignez les informations suivantes :',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Nom du commerce
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du commerce',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Le nom est obligatoire'
                            : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Quelques mots sur votre activité',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'La description est requise'
                            : null,
              ),
              const SizedBox(height: 16),

              // Catégorie du commerce
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  hintText: 'Ex : Restaurant, Escape Game…',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'La catégorie est obligatoire'
                            : null,
              ),
              const SizedBox(height: 16),

              // Latitude & Longitude (saisie manuelle)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requis';
                        }
                        final v = double.tryParse(value.trim());
                        return (v == null) ? 'Nombre invalide' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requis';
                        }
                        final v = double.tryParse(value.trim());
                        return (v == null) ? 'Nombre invalide' : null;
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Créer mon commerce'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
