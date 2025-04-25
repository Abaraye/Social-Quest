import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserTypeSelectorPage extends StatelessWidget {
  const UserTypeSelectorPage({Key? key}) : super(key: key);

  void _go(BuildContext ctx, String type) {
    ctx.push('/signup/$type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Création de compte"),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.question_mark,
                size: 72,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Qui êtes-vous ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Utilisateur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _go(context, 'user'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.store),
                label: const Text('Commerçant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _go(context, 'merchant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
