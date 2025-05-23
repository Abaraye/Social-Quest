import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mvp_social_quest/core/providers/repository_providers.dart';
import '../../core/utils/form_validators.dart';
import '../../widgets/forms/auth_form_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController(), _pass = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepoProvider)
          .signIn(email: _email.text.trim(), password: _pass.text.trim());
      if (mounted) GoRouter.of(context).go('/'); // AuthGate décidera
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Connexion'),
      leading: BackButton(onPressed: () => c.pop()),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Bienvenue 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              AuthFormField(
                controller: _email,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.email,
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _pass,
                label: 'Mot de passe',
                icon: Icons.lock,
                obscureText: true,
                validator: FormValidators.password,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Se connecter',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    ),
  );
}
