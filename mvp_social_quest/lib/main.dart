// lib/main.dart – v2.2
// 🔥 Initialisation Firebase + routing + thèmes + ProviderScope
// ✔️ Redirige vers AuthGate → Dashboard ou autres selon utilisateur
// ✔️ Fournit PartnerProvider en top‐level pour l’état du partenaire courant
// -------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'screens/auth/auth_gate.dart';
import 'providers/partner_provider.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR', null);
  // TODO: init Crashlytics / FCM ici si besoin
}

void main() {
  runZonedGuarded(
    () async {
      await _bootstrap();
      runApp(
        ChangeNotifierProvider(
          create: (_) => PartnerProvider(),
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      // ignore: avoid_print
      print('Uncaught zone error: $error');
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
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: generateRoute,
      home: const AuthGate(),
    );
  }
}
