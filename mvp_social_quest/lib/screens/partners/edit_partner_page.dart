// lib/screens/partners/edit_partner_page.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/services/firestore/partner/partner_service.dart';
import 'package:mvp_social_quest/widgets/partners/manage/header.dart';
import '../../models/partner/partner.dart';

/// ✏️ Page d’édition d’une activité existante
class EditPartnerPage extends StatefulWidget {
  final String partnerId;
  const EditPartnerPage({Key? key, required this.partnerId}) : super(key: key);

  @override
  State<EditPartnerPage> createState() => _EditPartnerPageState();
}

class _EditPartnerPageState extends State<EditPartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = '';
  bool _loading = true;

  // Liste fixe de catégories — vous pouvez la déplacer en constant ou service
  final List<String> _categories = [
    'Cuisine',
    'Sport',
    'Culture',
    'Jeux',
    'Bien-être',
    'Musique',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _loadPartner();
  }

  Future<void> _loadPartner() async {
    try {
      final partner = await PartnerService.getPartnerById(widget.partnerId);
      _nameCtrl.text = partner.name;
      _descCtrl.text = partner.description;
      _selectedCategory = partner.category;
    } catch (e) {
      // Gérer l'erreur au besoin
      debugPrint('Erreur chargement partenaire : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await PartnerService.updatePartner(
        partnerId: widget.partnerId,
        updates: {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'category': _selectedCategory,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Activité mise à jour ✅')));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l’enregistrement')),
        );
      }
      setState(() => _loading = false);
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
        title: const Text('Modifier mon activité'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: PartnerHeaderForm(
                  formKey: _formKey,
                  nameController: _nameCtrl,
                  descriptionController: _descCtrl,
                  selectedCategory: _selectedCategory,
                  categories: _categories,
                  onCategoryChanged: (c) {
                    if (c != null) setState(() => _selectedCategory = c);
                  },
                  onSubmit: _submit,
                  isEditing: true,
                  isLoading: _loading,
                ),
              ),
    );
  }
}
