// -----------------------------------------------------------------------------
// GoRouter – sprint-1-light (aucun import ni classe manquants)
// -----------------------------------------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/screens/auth/user_type_selector_page.dart';
import 'package:mvp_social_quest/screens/favorites/favorites_page.dart';
import 'package:mvp_social_quest/screens/profile/profile_page.dart';

// Models + stub service
import '../../models/partner.dart';
import '../../services/firestore/partner_service.dart';

// Pages utilisateur
import '../../screens/welcome/welcome_page.dart';
import '../../screens/auth/login_page.dart';
import '../../screens/auth/signup_page.dart';
import '../../screens/explore/explore_page.dart';
import '../../screens/explore/quest_page.dart';
import '../../screens/booking/booking_page.dart';
import '../../screens/booking/booking_details_page.dart';

// Pages commerçant existantes
import '../../screens/partners/partner_dashboard_page.dart';
import '../../screens/partners/partner_onboarding_page.dart';
import '../../screens/partners/partner_slots_calendar_page.dart';
import '../../screens/partners/quest_form_page.dart';
import '../../screens/partners/slot_form_page.dart';

// -----------------------------------------------------------------------------
// Transition fade générique
CustomTransitionPage<T> _fade<T>(Widget child) => CustomTransitionPage<T>(
  transitionsBuilder:
      (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
  child: child,
);

// -----------------------------------------------------------------------------
// Refresh notifier (auth + partenaires)
class _Refresh extends ChangeNotifier {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<List<Partner>>? _partnersSub;

  _Refresh() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  void _onAuth(User? user) {
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

final _refresh = _Refresh();

// -----------------------------------------------------------------------------
// Providers (singulier)
final partnerProvider = StreamProvider.autoDispose<List<Partner>>(
  (ref) => PartnerService.streamPartners(),
);

final userProfileProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((s) => s.data());
});

final userTypeProvider = Provider<String?>(
  (ref) => ref
      .watch(userProfileProvider)
      .maybeWhen(data: (d) => d?['type'] as String?, orElse: () => null),
);

// -----------------------------------------------------------------------------
// Router principal
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: _refresh,

    /* ------------------- redirect global ------------------- */
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.uri.toString();
      const pub = ['/welcome', '/login', '/signup'];
      final isPublic = pub.contains(loc) || loc.startsWith('/signup/');

      if (!loggedIn && !isPublic) return '/welcome';

      final type = ref.read(userTypeProvider);

      // Redirection marchands ➜ onboarding si pas encore de partenaire
      if (loggedIn && type == 'merchant') {
        final partnersAsync = ref.read(partnerProvider);
        return partnersAsync.maybeWhen(
          data: (list) {
            if (list.isEmpty && !loc.startsWith('/merchant/onboarding')) {
              return '/merchant/onboarding';
            }
            return null;
          },
          orElse: () => null,
        );
      }
      return null;
    },

    /* ------------------------ routes ----------------------- */
    routes: [
      // Public / Auth
      GoRoute(
        path: '/welcome',
        pageBuilder: (_, __) => _fade<void>(const WelcomePage()),
      ),
      GoRoute(path: '/login', pageBuilder: (_, __) => _fade(LoginPage())),
      GoRoute(
        path: '/signup',
        pageBuilder: (_, __) => _fade(const UserTypeSelectorPage()),
      ),
      GoRoute(
        path: '/signup/:userType',
        pageBuilder:
            (_, s) =>
                _fade(SignUpPage(userType: s.pathParameters['userType']!)),
      ),

      // ---------- Shell utilisateur (bottom-nav) ----------
      ShellRoute(
        builder: (_, __, child) => _UserShell(child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (_, __) => _fade(ExplorePage())),
          GoRoute(
            path: '/quest/:id',
            pageBuilder:
                (_, s) => _fade(QuestPage(questId: s.pathParameters['id']!)),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (_, __) => _fade(BookingPage()),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (_, __) => _fade(FavoritesPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => _fade(ProfilePage()),
          ),
          GoRoute(
            path: '/booking/:id',
            pageBuilder:
                (_, s) => _fade(
                  BookingDetailsPage(bookingId: s.pathParameters['id']!),
                ),
          ),
        ],
      ),

      // ---------------------- Merchant ----------------------
      GoRoute(
        path: '/merchant/onboarding',
        pageBuilder: (_, __) => _fade(PartnerOnboardingPage()),
      ),
      GoRoute(
        path: '/merchant/dashboard',
        pageBuilder: (_, __) => _fade(PartnerDashboardPage()),
      ),
      GoRoute(
        path: '/merchant/slots',
        pageBuilder: (_, __) => _fade(PartnerSlotsCalendarPage()),
      ),
      GoRoute(
        path: '/merchant/quest/form',
        pageBuilder: (_, __) => _fade(QuestFormPage()),
      ),
      GoRoute(
        path: '/merchant/slot/form',
        pageBuilder: (_, __) => _fade(SlotFormPage()),
      ),
    ],
  );
});

/* -------------------------------------------------------------------------- */
/*                                Shell UI                                    */
/* -------------------------------------------------------------------------- */

class _UserShell extends StatefulWidget {
  final Widget child;
  const _UserShell({Key? key, required this.child}) : super(key: key);

  @override
  State<_UserShell> createState() => __UserShellState();
}

class __UserShellState extends State<_UserShell> {
  int _current = 0;
  static const _tabs = ['/', '/bookings', '/favorites', '/profile'];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: widget.child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _current,
      onTap: (i) {
        if (i != _current) {
          setState(() => _current = i);
          context.go(_tabs[i]);
        }
      },
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
