// lib/core/routing/app_router.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart'
    show GoRouter, GoRoute, ShellRoute, GoRouterRefreshStream;

import 'package:mvp_social_quest/core/providers/auth_provider.dart';
import 'package:mvp_social_quest/screens/booking/partner_booking_detail_page.dart';
import 'package:mvp_social_quest/screens/partners/partner_edit_page.dart';

import '../providers/user_type_provider.dart';
import '../providers/partner_provider.dart';
import '../../models/partner.dart';
import '../../models/quest.dart';
import '../../models/slot.dart';

// Pages
import '../../screens/welcome/welcome_page.dart';
import '../../screens/auth/login_page.dart';
import '../../screens/auth/signup_page.dart';
import '../../screens/auth/user_type_selector_page.dart';
import '../../screens/explore/explore_page.dart';
import '../../screens/explore/quest_page.dart';
import '../../screens/explore/quest_detail_page.dart';
import '../../screens/booking/booking_page.dart';
import '../../screens/booking/booking_details_page.dart';
import '../../screens/favorites/favorites_page.dart';
import '../../screens/profile/profile_page.dart';
import '../../screens/partners/partner_onboarding_page.dart';
import '../../screens/partners/partner_dashboard_page.dart';
import '../../screens/booking/partner_bookings_page.dart';
import '../../screens/partners/partner_profile_page.dart';
import '../../screens/partners/partner_slots_calendar_page.dart';
import '../../screens/splash/splash_page.dart';

// Nav
import '../../core/navigation/user_nav_items.dart' as user_nav;
import '../../core/navigation/merchant_nav_items.dart' as merchant_nav;

// Auth
import '../../widgets/auth_gate.dart';

CustomTransitionPage<T> _fade<T>(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder:
      (_, anim, __, c) => FadeTransition(opacity: anim, child: c),
);

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  print('[routerProvider] auth.state = ${auth.value}');

  if (auth.isLoading) {
    return GoRouter(
      routes: [GoRoute(path: '/', builder: (_, __) => const SplashPage())],
    );
  }

  final user = auth.value;
  final loggedIn = user != null;

  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: _AuthChangeNotifier(),

    redirect: (ctx, state) {
      final loc = state.matchedLocation;
      final user = auth.value;

      if (user == null &&
          !['/login', '/signup', '/welcome'].any(loc.startsWith)) {
        return '/welcome';
      }

      // 1️⃣ attendre userTypeProvider
      final userTypeAsync = ref.watch(userTypeProvider);
      if (userTypeAsync.isLoading) return null;
      final userType = userTypeAsync.value;

      // 2️⃣ logique marchand
      if (userType == 'merchant') {
        final partnersAsync = ref.watch(partnerListProvider);
        if (partnersAsync.isLoading) return null;

        final partners = partnersAsync.value ?? [];
        if (partners.isEmpty && !loc.startsWith('/merchant/onboarding')) {
          return '/merchant/onboarding';
        }
        if (partners.isNotEmpty && !loc.startsWith('/dashboard')) {
          return '/dashboard/${partners.first.id}';
        }
      }

      // 3️⃣ logique user
      if (userType == 'user' && !loc.startsWith('/home')) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (_, __) => _fade(const WelcomePage()),
      ),
      GoRoute(path: '/login', pageBuilder: (_, __) => _fade(const LoginPage())),
      GoRoute(
        path: '/signup',
        pageBuilder: (_, __) => _fade(const UserTypeSelectorPage()),
      ),
      GoRoute(
        path: '/signup/:userType',
        pageBuilder:
            (_, st) =>
                _fade(SignupPage(userType: st.pathParameters['userType']!)),
      ),
      GoRoute(
        path: '/merchant/onboarding',
        pageBuilder: (_, __) => _fade(const PartnerOnboardingPage()),
      ),
      ShellRoute(
        builder: (_, __, child) => _MerchantShell(child: child),
        routes: [
          // 1️⃣ route dashboard RELATIVE
          GoRoute(
            path: '/dashboard/:pid',
            pageBuilder:
                (_, st) => _fade(
                  PartnerDashboardPage(partnerId: st.pathParameters['pid']!),
                ),
            routes: [
              // 2️⃣ toutes RELATIVES
              GoRoute(
                path: 'bookings',
                pageBuilder:
                    (_, st) => _fade(
                      PartnerBookingsPage(partnerId: st.pathParameters['pid']!),
                    ),
              ),
              GoRoute(
                path: 'profile',
                pageBuilder:
                    (_, st) => _fade(
                      PartnerProfilePage(partnerId: st.pathParameters['pid']!),
                    ),
              ),

              GoRoute(
                path: 'quest/:qid',
                pageBuilder:
                    (_, st) => _fade(
                      QuestDetailPage(
                        partnerId: st.pathParameters['pid']!,
                        questId: st.pathParameters['qid']!,
                      ),
                    ),
                routes: [
                  GoRoute(
                    path: 'slots',
                    pageBuilder:
                        (_, st) => _fade(
                          PartnerSlotsCalendarPage(
                            partnerId: st.pathParameters['pid']!,
                            questId: st.pathParameters['qid']!,
                          ),
                        ),
                    routes: [],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      ShellRoute(
        builder: (c, s, child) => _UserShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => _fade(const ExplorePage()),
            routes: [
              GoRoute(
                path: 'quest/:id',
                pageBuilder:
                    (_, st) =>
                        _fade(QuestPage(questId: st.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'bookings',
                pageBuilder: (_, __) => _fade(const BookingPage()),
              ),
              GoRoute(
                path: 'booking/:id',
                pageBuilder:
                    (_, st) => _fade(
                      BookingDetailsPage(bookingId: st.pathParameters['id']!),
                    ),
              ),
              GoRoute(
                path: 'favorites',
                pageBuilder: (_, __) => _fade(const FavoritesPage()),
              ),
              GoRoute(
                path: 'profile',
                pageBuilder: (_, __) => _fade(const ProfilePage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dashboard/partner/new',
        pageBuilder: (_, __) => _fade(const PartnerEditPage()),
      ),
      GoRoute(
        path: '/dashboard/partner/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _fade(PartnerEditPage(partnerId: id));
        },
      ),
      GoRoute(
        path: '/dashboard/:pid/booking/:bid',
        pageBuilder:
            (_, st) => _fade(
              PartnerBookingDetailsPage(bookingId: st.pathParameters['bid']!),
            ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (_, __) => _fade(const AuthGate(child: SizedBox())),
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _UserShell extends StatelessWidget {
  const _UserShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext c) {
    final idx = user_nav.indexFromPath(GoRouterState.of(c).matchedLocation);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => c.go(user_nav.userNavItems[i].path),
        selectedItemColor: Theme.of(c).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          for (final it in user_nav.userNavItems)
            BottomNavigationBarItem(icon: Icon(it.icon), label: it.label),
        ],
      ),
    );
  }
}

class _MerchantShell extends StatelessWidget {
  const _MerchantShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext c) {
    final st = GoRouterState.of(c);
    final pid = st.pathParameters['pid']!;
    final idx = merchant_nav.indexFromPath(pid, st.matchedLocation);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => c.go(merchant_nav.merchantNavItems[i].buildPath(pid)),
        items: [
          for (final it in merchant_nav.merchantNavItems)
            BottomNavigationBarItem(icon: Icon(it.icon), label: it.label),
        ],
      ),
    );
  }
}
