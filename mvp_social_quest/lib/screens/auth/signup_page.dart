import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/core/providers/user_provider.dart';
import 'package:mvp_social_quest/models/user.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/user_type_provider.dart';
import '../../../core/utils/form_validators.dart';
import '../../../widgets/forms/auth_form_field.dart';

class SignupPage extends ConsumerStatefulWidget {
  final String userType;
  const SignupPage({super.key, required this.userType});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authRepo = ref.read(authRepoProvider);
      final userRepo = ref.read(userRepoProvider);

      // Création du compte Firebase Auth
      final userCredential = await authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        throw Exception("Erreur lors de la création du compte");
      }

      // Création du modèle utilisateur
      final userModel = AppUser(
        id: userId,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        type: widget.userType, // ✅ rôle dynamique
        favorites: [],
      );

      await userRepo.save(userModel);

      // 🔄 force le refresh pour le redirect
      ref.invalidate(userTypeProvider);
      ref.invalidate(currentUserProvider);

      context.go('/'); // Le GoRouter prendra la suite automatiquement
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthFormField(
                controller: _nameController,
                label: "Nom",
                validator: FormValidators.validateRequired,
              ),
              const SizedBox(height: 12),
              AuthFormField(
                controller: _emailController,
                label: "Email",
                validator: FormValidators.email,
              ),
              const SizedBox(height: 12),
              AuthFormField(
                controller: _passwordController,
                label: "Mot de passe",
                obscureText: true,
                validator: FormValidators.password,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
