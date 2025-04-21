// =============================================================
// lib/screens/partners/manage_partner_page.dart – v2.4
// =============================================================
// ✨ Page permettant de créer, modifier ou supprimer une activité commerçante
// 🧼 Corrige le bug `setState after dispose`
// ✅ Redirige vers le dashboard commerçant après création ou suppression
// -------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/partners/manage/header.dart';

class ManagePartnerPage extends StatefulWidget {
  final String? partnerId;

  const ManagePartnerPage({super.key, this.partnerId});

  @override
  State<ManagePartnerPage> createState() => _ManagePartnerPageState();
}

class _ManagePartnerPageState extends State<ManagePartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCat = 'Cuisine';

  final _cats = [
    'Cuisine',
    'Sport',
    'Culture',
    'Jeux',
    'Bien-être',
    'Musique',
    'Autre',
  ];

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.partnerId != null) {
      _loadPartnerData();
    }
  }

  Future<void> _loadPartnerData() async {
    setState(() => _isLoading = true);
    final doc =
        await FirebaseFirestore.instance
            .collection('partners')
            .doc(widget.partnerId)
            .get();

    if (!mounted) return;

    if (doc.exists) {
      final d = doc.data()!;
      _nameCtrl.text = d['name'] ?? '';
      _descCtrl.text = d['description'] ?? '';
      _selectedCat = d['category'] ?? 'Cuisine';
      setState(() => _isEditMode = true);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      'ownerId': user.uid,
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _selectedCat,
      'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() => _isLoading = true);

    if (_isEditMode && widget.partnerId != null) {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .update(data);
    } else {
      await FirebaseFirestore.instance.collection('partners').add(data);
      _nameCtrl.clear();
      _descCtrl.clear();
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode ? 'Activité mise à jour' : 'Activité créée avec succès',
        ),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer cette activité ?'),
            content: const Text(
              'Cette action est irréversible. Toutes les données associées seront perdues.',
            ),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Supprimer'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );

    if (confirm == true && widget.partnerId != null) {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partnerId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Activité supprimée')));
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ManagePartnerHeader(
                      formKey: _formKey,
                      nameController: _nameCtrl,
                      descriptionController: _descCtrl,
                      selectedCategory: _selectedCat,
                      categories: _cats,
                      onCategoryChanged:
                          (c) => setState(() => _selectedCat = c ?? 'Cuisine'),
                      onCreate: _handleSave,
                      isEditing: _isEditMode,
                    ),
                    if (_isEditMode) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text("Supprimer l'activité"),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
