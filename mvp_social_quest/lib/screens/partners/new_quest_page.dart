import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/widgets/partners/manage/header.dart';

class NewQuestPage extends StatefulWidget {
  final String partnerId;
  const NewQuestPage({Key? key, required this.partnerId}) : super(key: key);

  @override
  State<NewQuestPage> createState() => _NewQuestPageState();
}

class _NewQuestPageState extends State<NewQuestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Sport';
  final List<String> _categories = [
    'Sport',
    'Cuisine',
    'Bien-être',
    'Aventure',
  ];
  bool _isLoading = false;

  Future<void> _createQuest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance.collection('quests').add({
        'title': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategory,
        'partnerId': widget.partnerId,
        'priceCents': 0,
        'currency': 'EUR',
        'isActive': true,
        'photos': <String>[],
        'reductions': <Map>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activité créée avec succès')),
      );
      // redirige vers la fiche questDetail
      context.go('/quest/${doc.id}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur création activité : $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle activité')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PartnerHeaderForm(
          formKey: _formKey,
          nameController: _nameCtrl,
          descriptionController: _descCtrl,
          selectedCategory: _selectedCategory,
          categories: _categories,
          onCategoryChanged: (c) => setState(() => _selectedCategory = c!),
          onSubmit: _createQuest,
          isEditing: false,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
