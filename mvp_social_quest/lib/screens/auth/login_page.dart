import 'package:flutter/material.dart';
import 'package:mvp_social_quest/services/auth/auth_service.dart';
import 'package:mvp_social_quest/screens/home/home_page.dart';
import 'package:mvp_social_quest/widgets/auth/auth_form_field.dart';
import 'package:mvp_social_quest/core/utils/form_validators.dart';

/// 🔐 Page de connexion utilisateur
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  /// 🔁 Connexion via Firebase Auth
  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      final user = await AuthService.signIn(email, password);
      if (context.mounted && user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connecté avec succès en tant que ${user.email}"),
          ),
        );
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🧱 Interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bienvenue de retour 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 📧 Email
                AuthFormField(
                  controller: emailController,
                  label: 'Adresse email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidators.email,
                ),

                const SizedBox(height: 16),

                // 🔐 Mot de passe
                AuthFormField(
                  controller: passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: FormValidators.password,
                ),

                const SizedBox(height: 24),

                // 🔘 Bouton de connexion
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              _handleLogin();
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Se connecter',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
