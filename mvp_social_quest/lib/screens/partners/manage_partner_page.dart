// lib/screens/partners/manage_partner_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_partner_page.dart';
import '../../widgets/partners/manage/header.dart';

/// 🔧 Page permettant aux commerçants de créer et visualiser leurs activités
class ManagePartnerPage extends StatefulWidget {
  const ManagePartnerPage({super.key});

  @override
  State<ManagePartnerPage> createState() => _ManagePartnerPageState();
}

class _ManagePartnerPageState extends State<ManagePartnerPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> categories = [
    'Cuisine',
    'Sport',
    'Culture',
    'Jeux',
    'Bien-être',
    'Musique',
    'Autre',
  ];
  String selectedCategory = 'Cuisine';

  bool isLoading = true;
  List<Map<String, dynamic>> partners = [];

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  /// 🔁 Récupère les activités du commerçant connecté
  Future<void> _loadPartners() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('partners')
            .where('ownerId', isEqualTo: user.uid)
            .get();

    if (mounted) {
      setState(() {
        partners =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
        isLoading = false;
      });
    }
  }

  /// ➕ Création d'une nouvelle activité pour le commerçant connecté
  Future<void> _createPartner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('partners').add({
      'ownerId': user.uid,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() {
        partners.add({
          'id': doc.id,
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          'category': selectedCategory,
        });
        nameController.clear();
        descriptionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes activités"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Formulaire de création d'une nouvelle activité
            ManagePartnerHeader(
              formKey: _formKey,
              nameController: nameController,
              descriptionController: descriptionController,
              selectedCategory: selectedCategory,
              categories: categories,
              onCategoryChanged:
                  (value) => setState(() => selectedCategory = value ?? ''),
              onCreate: () {
                if (_formKey.currentState!.validate()) _createPartner();
              },
            ),

            const SizedBox(height: 32),
            const Text(
              "Mes activités",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (partners.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Aucune activité créée pour ce compte."),
              ),

            /// 🔹 Liste des cartes des activités existantes avec bouton Gérer
            ...partners.map(
              (partner) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(partner['name'] ?? ''),
                  subtitle: Text(partner['description'] ?? ''),
                  trailing: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditPartnerPage(
                                  partnerId: partner['id'],
                                  partnerName: partner['name'],
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        "Gérer",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
