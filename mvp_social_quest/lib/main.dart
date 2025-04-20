// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // 🛠 Config auto-générée pour Firebase
import 'screens/auth/welcome_page.dart';
import 'screens/home/home_page.dart'; // 🔄 Sera utilisé plus tard si l’utilisateur est déjà connecté

void main() async {
  // ✅ Obligatoire pour utiliser Firebase avant le lancement complet de l'app
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialisation Firebase avec les options selon la plateforme
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Quest',
      debugShowCheckedModeBanner: false,

      // 🎨 Thème global : couleur, typographie, AppBar, etc.
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),

      // 🏠 Page d’accueil (non-connecté)
      home: const WelcomePage(),
    );
  }
}
