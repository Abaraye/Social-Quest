// lib/core/router/app_router.dart
// -----------------------------------------------------------------------------
// Gestion centralisée des routes de Social Quest avec GoRouter et Riverpod.
// Fait le lien avec l'état FirebaseAuth et Firestore (/users/{uid}) pour
// rafraîchir la navigation dynamiquement (rôle, onboarding, partenaires).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modèle & services
import 'package:mvp_social_quest/models/partner/partner.dart';
import 'package:mvp_social_quest/services/firestore/partner/partner_service.dart';

// Écrans d’authentification
import 'package:mvp_social_quest/screens/auth/welcome_page.dart';
import 'package:mvp_social_quest/screens/auth/login_page.dart';
import 'package:mvp_social_quest/screens/auth/user_type_selector_page.dart';
import 'package:mvp_social_quest/screens/auth/signup_page.dart';

// Écran de création de commerce (Partner)
import 'package:mvp_social_quest/screens/partners/partner_form_creation_page.dart';

// Écrans utilisateur
import 'package:mvp_social_quest/screens/home/home_page.dart';
import 'package:mvp_social_quest/screens/bookings/my_bookings_page.dart';
import 'package:mvp_social_quest/screens/favorites/favorites_page.dart';
import 'package:mvp_social_quest/screens/profile/profile_page.dart';
import 'package:mvp_social_quest/screens/quest/quest_detail_page.dart';

// Écrans marchand
import 'package:mvp_social_quest/screens/partners/merchant_dashboard_home.dart';
import 'package:mvp_social_quest/screens/bookings/partner_bookings_page.dart';
import 'package:mvp_social_quest/screens/partners/fill_rate_detail_page.dart';
import 'package:mvp_social_quest/screens/partners/new_quest_page.dart';
import 'package:mvp_social_quest/screens/partners/manage_partner_slots_page.dart';
import 'package:mvp_social_quest/screens/partners/manage_partner_page.dart';

/// 🔄 Notifier pour rafraîchir GoRouter à chaque changement :
///  • Auth (connexion/déconnexion)
///  • Profil Firestore (/users/{uid}) pour le type d'utilisateur
///  • Liste des partners pour onboarding → dashboard
class AppRefreshNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<List<Partner>>? _partnersSub;

  AppRefreshNotifier() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
  }

  void _onAuthChange(User? user) {
    notifyListeners();
    _profileSub?.cancel();
    _partnersSub?.cancel();
    if (user != null) {
      _profileSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((_) => notifyListeners());
      _partnersSub = PartnerService.streamPartners().listen(
        (_) => notifyListeners(),
      );
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    _partnersSub?.cancel();
    super.dispose();
  }
}

final _refreshNotifier = AppRefreshNotifier();

/// ── Provider Riverpod : liste des partenaires actifs de l'utilisateur courant ──
final partnerListProvider = StreamProvider.autoDispose<List<Partner>>((ref) {
  return PartnerService.streamPartners();
});

/// ── Provider Riverpod : premier partnerId ou null ──
final firstPartnerIdProvider = Provider<String?>((ref) {
  final asyncList = ref.watch(partnerListProvider);
  return asyncList.maybeWhen(
    data: (list) => list.isNotEmpty ? list.first.id : null,
    orElse: () => null,
  );
});

/// ── Provider Riverpod : profil utilisateur courant (données Firestore) ──
final userProfileProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data());
});

/// ── Provider Riverpod : type d'utilisateur ('merchant' ou autre) ──
final userTypeProvider = Provider<String?>((ref) {
  final asyncProfile = ref.watch(userProfileProvider);
  return asyncProfile.maybeWhen(
    data: (data) => data?['type'] as String?,
    orElse: () => null,
  );
});

/// ── RootShell : choix dynamique du shell selon la présence de partnerId ──
class RootShell extends StatelessWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final pid = GoRouterState.of(context).pathParameters['partnerId'];
    if (pid != null) return MerchantShell(partnerId: pid, child: child);
    return HomePageShell(child: child);
  }
}

/// ── Shell utilisateur ──
class HomePageShell extends StatefulWidget {
  const HomePageShell({super.key, required this.child});
  final Widget child;
  @override
  State<HomePageShell> createState() => _HomePageShellState();
}

class _HomePageShellState extends State<HomePageShell> {
  int _current = 0;
  static const _paths = ['/', '/bookings', '/favorites', '/profile'];
  void _onTap(int i) {
    if (_current == i) return;
    setState(() => _current = i);
    context.go(_paths[i]);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: widget.child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _current,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorer'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Réservations'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    ),
  );
}

/// ── Shell marchand ──
class MerchantShell extends StatefulWidget {
  final String partnerId;
  final Widget child;
  const MerchantShell({
    super.key,
    required this.partnerId,
    required this.child,
  });
  @override
  State<MerchantShell> createState() => _MerchantShellState();
}

class _MerchantShellState extends State<MerchantShell> {
  int _current = 0;
  List<String> get _routes => [
    '/dashboard/${widget.partnerId}',
    '/dashboard/${widget.partnerId}/bookings',
    '/dashboard/${widget.partnerId}/profile',
  ];
  void _onTap(int i) {
    if (_current == i) return;
    setState(() => _current = i);
    context.go(_routes[i]);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: widget.child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _current,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Réservations'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    ),
  );
}

/// ── Provider Riverpod : GoRouter encapsulé avec écoute multiple ──
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/welcome',
    refreshListenable: _refreshNotifier,
    redirect: (context, state) {
      // Lecture utilisateur courant
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loc = state.uri.toString();
      const publicPaths = ['/welcome', '/login', '/signup'];
      final isPublic = publicPaths.contains(loc) || loc.startsWith('/signup/');

      // 1️⃣ Non connecté → welcome
      if (!loggedIn && !isPublic) {
        return '/welcome';
      }

      // 2️⃣ Marchand connecté → onboarding ou dashboard
      final type = ref.read(userTypeProvider);
      if (loggedIn && type == 'merchant') {
        final firstId = ref.read(firstPartnerIdProvider);
        // A) pas de partner → formulaire creation
        if (firstId == null && loc != '/partner-form') {
          return '/partner-form';
        }
        // B) a au moins un partner → dashboard
        if (firstId != null && !loc.startsWith('/dashboard/')) {
          return '/dashboard/$firstId';
        }
        // déjà sur partner-form ou dashboard → rien
        return null;
      }

      // 3️⃣ Utilisateur standard connecté → explorer
      if (loggedIn && type != 'merchant') {
        if (!loc.startsWith('/')) return '/';
        return null;
      }

      // 4️⃣ Ecrans publics → rien
      return null;
    },
    routes: [
      // Authentification
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const UserTypeSelectorPage(),
      ),
      GoRoute(
        path: '/signup/:userType',
        builder:
            (_, state) =>
                SignUpPage(userType: state.pathParameters['userType']!),
      ),

      // Formulaire Partner
      GoRoute(
        path: '/partner-form',
        pageBuilder:
            (_, __) => const MaterialPage(
              fullscreenDialog: true,
              child: PartnerFormCreationPage(),
            ),
      ),

      // Shell racine (utilisateur ou marchand)
      ShellRoute(
        builder: (ctx, state, child) => RootShell(child: child),
        routes: [
          // UTILISATEUR
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(
            path: '/bookings',
            builder: (_, __) => const MyBookingsPage(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesPage(),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(
            path: '/quest/:id',
            pageBuilder:
                (_, state) => MaterialPage(
                  key: state.pageKey,
                  child: QuestDetailPage(questId: state.pathParameters['id']!),
                ),
          ),

          // MARCHAND
          GoRoute(
            path: '/dashboard/:partnerId',
            name: 'dashboard',
            builder:
                (_, state) => MerchantDashboardHome(
                  partnerId: state.pathParameters['partnerId']!,
                ),
          ),
          GoRoute(
            path: '/dashboard/:partnerId/bookings',
            builder:
                (_, state) => PartnerBookingsPage(
                  partnerId: state.pathParameters['partnerId']!,
                ),
          ),
          GoRoute(
            path: '/dashboard/:partnerId/profile',
            builder: (_, __) => const ProfilePage(),
          ),
          GoRoute(
            path: '/dashboard/:partnerId/quest/new',
            builder:
                (_, state) =>
                    NewQuestPage(partnerId: state.pathParameters['partnerId']!),
          ),
          GoRoute(
            path: '/dashboard/:partnerId/slots',
            builder:
                (_, state) => ManagePartnerSlotsPage(
                  partnerId: state.pathParameters['partnerId']!,
                ),
          ),
          GoRoute(
            path: '/dashboard/:partnerId/fill-rate',
            builder:
                (_, state) => FillRateDetailPage(
                  partnerId: state.pathParameters['partnerId']!,
                ),
          ),
        ],
      ),

      // Gestion globale des partners (hors shells)
      GoRoute(
        path: '/manage/:partnerId',
        builder:
            (_, state) => ManagePartnerPage(
              partnerId: state.pathParameters['partnerId']!,
            ),
      ),
    ],
  );
});
