import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvp_social_quest/services/auth/auth_service.dart';
import 'package:mvp_social_quest/screens/home/home_page.dart';
import 'package:mvp_social_quest/widgets/auth/auth_form_field.dart';
import 'package:mvp_social_quest/core/utils/form_validators.dart';

/// 🔐 Page d’inscription utilisateur (type: user ou merchant)
class SignUpPage extends StatefulWidget {
  final String userType;
  const SignUpPage({super.key, required this.userType});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  /// 🔄 Enregistrement de l'utilisateur (Firebase Auth + Firestore)
  Future<void> _handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      final user = await AuthService.signUp(email, password);

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'type': widget.userType,
          'createdAt': FieldValue.serverTimestamp(),
          'favorites': [],
        });

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🧱 Interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un compte"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Inscription ✨',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 🔤 Nom
                  AuthFormField(
                    controller: nameController,
                    label: 'Prénom ou pseudo',
                    icon: Icons.person,
                    validator: FormValidators.requiredField,
                  ),
                  const SizedBox(height: 16),

                  // 📧 Email
                  AuthFormField(
                    controller: emailController,
                    label: 'Adresse email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.email,
                  ),
                  const SizedBox(height: 16),

                  // 🔒 Mot de passe
                  AuthFormField(
                    controller: passwordController,
                    label: 'Mot de passe (min. 6 caractères)',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: FormValidators.password,
                  ),
                  const SizedBox(height: 24),

                  // ✅ Bouton
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                _handleSignUp();
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Créer un compte'),
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
