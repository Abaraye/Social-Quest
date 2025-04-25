// lib/screens/partners/create_partner_page.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/screens/home/home_page.dart';
import 'package:mvp_social_quest/services/firestore/auth/auth_service.dart';
import 'package:mvp_social_quest/services/firestore/partner/partner_service.dart';
import '../../widgets/common/rounded_button.dart';

/// 🏁 Inscription + création de la première activité commerçant.
class CreatePartnerPage extends StatefulWidget {
  const CreatePartnerPage({Key? key}) : super(key: key);

  @override
  State<CreatePartnerPage> createState() => _CreatePartnerPageState();
}

class _CreatePartnerPageState extends State<CreatePartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // 1️⃣ Création du compte Auth
      final user = await AuthService.signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (user == null) throw Exception('Impossible de créer le compte.');

      // 2️⃣ Création du profil utilisateur Firestore
      await PartnerService.createUserProfile(
        userId: user.uid,
        email: user.email!,
        name: _nameCtrl.text.trim(),
      );

      // 3️⃣ Création de la 1ʳᵉ activité
      await PartnerService.createPartner(
        name: _nameCtrl.text.trim(),
        description: _categoryCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        latitude: 0.0,
        longitude: 0.0,
      );

      // 4️⃣ Une fois tout OK, retour à l’accueil
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte commerçant')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nom
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom de votre activité',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        v != null && v.contains('@') ? null : 'Email invalide',
              ),
              const SizedBox(height: 16),

              // Mot de passe
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe (≥ 6 caractères)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (v) => v != null && v.length >= 6 ? null : 'Trop court',
              ),
              const SizedBox(height: 16),

              // Catégorie
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catégorie de l’activité',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

              // Bouton
              RoundedButton(
                onPressed:
                    _loading
                        ? null
                        : () {
                          _submit();
                        },
                child:
                    _loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Créer mon compte & activité'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
