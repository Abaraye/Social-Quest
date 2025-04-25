// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart'; // contient routerProvider
import 'screens/auth/auth_gate.dart';

/// Initialise Firebase et la localisation
Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR', null);
}

void main() {
  runZonedGuarded(
    () async {
      await _bootstrap();
      // ProviderScope pour Riverpod (providers définis dans app_router)
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      // Gestion des erreurs non capturées
      debugPrint('Uncaught zone error: \$error');
    },
  );
}

/// Point d'entrée de l'application
/// Utilise ConsumerWidget pour accéder aux providers Riverpod
class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère le router configuré via routerProvider
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
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

      /// AuthGate vérifie l'état d'authentification avant d'afficher l'app
      builder: (context, child) => AuthGate(child: child!),
      routerConfig: goRouter,
    );
  }
}
