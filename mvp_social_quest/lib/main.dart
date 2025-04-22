// =============================================================
// lib/main.dart – v2.1
// =============================================================
// 🔥 Initialisation Firebase + routing + thèmes
// ✔️ Redirige vers AuthGate → Dashboard ou autres selon utilisateur
// -------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mvp_social_quest/core/router/app_router.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR', null);
  // Init Crashlytics / FCM lazy here…
}

void main() {
  runZonedGuarded(
    () async {
      await _bootstrap();
      runApp(const MyApp());
    },
    (error, stack) {
      print('Uncaught zone error: \$error');
      // FirebaseCrashlytics.instance.recordError(error, stack);
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
    );
  }
}
