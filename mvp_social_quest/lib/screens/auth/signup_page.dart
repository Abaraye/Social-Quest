// lib/screens/auth/signup_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/services/firestore/auth/auth_service.dart';
import 'package:mvp_social_quest/widgets/auth/auth_form_field.dart';
import 'package:mvp_social_quest/core/utils/form_validators.dart';

/// Page d'inscription
/// ------------------
/// • Crée l'utilisateur et le profil Firestore (`type`, `favorites`...)
/// • En cas de succès, redirige vers `/` (HomePage) pour déclencher la logique de redirect
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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (user == null) throw Exception('Inscription refusée');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': _emailCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'type': widget.userType,
        'favorites': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      // Redirige vers HomePage ('/') pour déclencher la logique de redirect
      context.go('/');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                  AuthFormField(
                    controller: _nameCtrl,
                    label: 'Nom ou pseudo',
                    icon: Icons.person,
                    validator: FormValidators.requiredField,
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _emailCtrl,
                    label: 'Adresse email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.email,
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _passCtrl,
                    label: 'Mot de passe (min. 6 car.)',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: FormValidators.password,
                  ),
                  const SizedBox(height: 24),
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
