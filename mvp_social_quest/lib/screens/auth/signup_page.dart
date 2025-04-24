import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/services/auth/auth_service.dart';
import 'package:mvp_social_quest/screens/home/home_page.dart';
import 'package:mvp_social_quest/widgets/auth/auth_form_field.dart';
import 'package:mvp_social_quest/core/utils/form_validators.dart';

/// 🔐 Page d’inscription (type “user” ou “merchant”).
class SignUpPage extends StatefulWidget {
  final String userType;
  const SignUpPage({Key? key, required this.userType}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// 📋 Crée un compte Firebase + enregistre le profil en Firestore.
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': _emailCtrl.text.trim(),
          'name': _nameCtrl.text.trim(),
          'type': widget.userType,
          'favorites': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (_) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur d\'inscription : $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Inscription',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // Nom / pseudo
                  AuthFormField(
                    controller: _nameCtrl,
                    label: 'Nom ou pseudo',
                    icon: Icons.person,
                    validator: FormValidators.requiredField,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  AuthFormField(
                    controller: _emailCtrl,
                    label: 'Adresse email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.email,
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe
                  AuthFormField(
                    controller: _passCtrl,
                    label: 'Mot de passe (min. 6 caractères)',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: FormValidators.password,
                  ),
                  const SizedBox(height: 24),

                  // Bouton
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Créer un compte'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
