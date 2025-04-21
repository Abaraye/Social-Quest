import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mvp_social_quest/core/theme/app_theme.dart';
import 'package:mvp_social_quest/firebase_options.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null); // 💡 Ajout pour le français
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
      theme: AppTheme.main,
      home: const AuthGate(),
    );
  }
}
