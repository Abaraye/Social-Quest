import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return auth.value == null ? child : const SizedBox(); // déjà redirigé
  }
}
