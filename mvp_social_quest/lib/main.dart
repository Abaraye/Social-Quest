// =============================================================
// lib/main.dart – v2.1
// =============================================================
// 🔥 Initialisation Firebase + routing + thèmes
// ✅ Ajout de la route '/dashboard' vers MerchantDashboardWrapper
// -------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mvp_social_quest/core/router/app_router.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/partners/merchant_dashboard_wrapper.dart'; // ✅ Ajout

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR', null);
}

void main() {
  runZonedGuarded(
    () async {
      await _bootstrap();
      runApp(const MyApp());
    },
    (error, stack) {
      print('Uncaught zone error: $error');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Quest',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      onGenerateRoute: generateRoute,
      home: const AuthGate(),
      routes: {
        '/dashboard':
            (context) =>
                const MerchantDashboardWrapper(), // ✅ Route dashboard commerçant
      },
    );
  }
}
