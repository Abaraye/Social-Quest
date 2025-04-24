// lib/screens/partners/manage_partner_page.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/services/firestore/partner_service.dart';
import 'package:mvp_social_quest/widgets/common/delete_button.dart';
import 'package:mvp_social_quest/widgets/partners/manage/header.dart';

/// 🧩 Page création / édition d’une activité commerçant.
/// Si [partnerId] == null ⇒ création, sinon édition.
class ManagePartnerPage extends StatefulWidget {
  final String? partnerId;
  const ManagePartnerPage({Key? key, this.partnerId}) : super(key: key);

  @override
  State<ManagePartnerPage> createState() => _ManagePartnerPageState();
}

class _ManagePartnerPageState extends State<ManagePartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Cuisine';
  final List<String> _categories = [
    'Cuisine',
    'Sport',
    'Culture',
    'Jeux',
    'Bien-être',
    'Musique',
    'Autre',
  ];

  bool _isLoading = false;
  bool get _isEditMode => widget.partnerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) _loadExistingPartner();
  }

  Future<void> _loadExistingPartner() async {
    setState(() => _isLoading = true);
    try {
      final p = await PartnerService.getPartnerById(widget.partnerId!);
      // On utilise directement les getters exposés
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _selectedCategory = p.category;
    } catch (e) {
      debugPrint('⚠️ chargement partenaire : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _selectedCategory,
    };

    try {
      if (_isEditMode) {
        await PartnerService.updatePartner(
          partnerId: widget.partnerId!,
          updates: data,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Activité mise à jour ✅')));
      } else {
        await PartnerService.createPartner(
          name: data['name']!,
          description: data['description']!,
          category: data['category']!,
          latitude: 0.0,
          longitude: 0.0,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Activité créée 🎉')));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('⚠️ sauvegarde partenaire : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l’enregistrement')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Supprimer cette activité ?'),
            content: const Text(
              'Cette action est irréversible et supprime toutes les données associées.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (ok == true && mounted) {
      await PartnerService.deactivatePartner(widget.partnerId!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Activité supprimée ❌')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Modifier mon activité' : 'Nouvelle activité',
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    PartnerHeaderForm(
                      formKey: _formKey,
                      nameController: _nameCtrl,
                      descriptionController: _descCtrl,
                      selectedCategory: _selectedCategory,
                      categories: _categories,
                      onCategoryChanged: (c) {
                        if (c != null) setState(() => _selectedCategory = c);
                      },
                      onSubmit: _handleSave,
                      isEditing: _isEditMode,
                      isLoading: _isLoading,
                    ),
                    if (_isEditMode) ...[
                      const SizedBox(height: 24),
                      DeleteButton(
                        label: 'Supprimer l’activité',
                        onPressed: _handleDelete,
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
