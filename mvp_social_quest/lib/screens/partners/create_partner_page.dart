import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvp_social_quest/screens/home/home_page.dart';

/// Écran pour l'inscription d’un commerçant et la création de sa première activité.
class CreatePartnerPage extends StatefulWidget {
  const CreatePartnerPage({super.key});

  @override
  State<CreatePartnerPage> createState() => _CreatePartnerPageState();
}

class _CreatePartnerPageState extends State<CreatePartnerPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de champs de formulaire
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  /// Fonction principale pour créer le compte Firebase + activité partenaire
  Future<void> _handleSignUpAndCreatePartner() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final category = categoryController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation simple
    if ([name, description, category, email, password].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de remplir tous les champs')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔐 Création du compte Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user != null) {
        // 🔹 Enregistrement dans la collection users
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'type': 'merchant', // On uniformise avec les autres pages
          'createdAt': FieldValue.serverTimestamp(),
          'favorites': [],
        });

        // 🔹 Création de la première activité dans partners
        await FirebaseFirestore.instance.collection('partners').add({
          'name': name,
          'description': description,
          'category': category,
          'ownerId': user.uid,
          'latitude': 0.0,
          'longitude': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Compte commerçant créé avec succès ✅"),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte commerçant'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Créer une activité 🎯',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 🔹 Nom de l’activité
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l’activité',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Catégorie
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Catégorie requise' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Email requis' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Mot de passe
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe (min. 6 caractères)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        value!.length < 6 ? 'Mot de passe trop court' : null,
              ),
              const SizedBox(height: 24),

              // 🔹 Bouton de validation
              ElevatedButton.icon(
                onPressed: isLoading ? null : _handleSignUpAndCreatePartner,
                icon: const Icon(Icons.business),
                label:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Créer un compte commerçant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
