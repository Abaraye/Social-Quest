import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mvp_social_quest/screens/partners/merchant_dashboard_home.dart';
import 'package:mvp_social_quest/screens/partners/partners_list_page.dart';
import 'package:mvp_social_quest/screens/bookings/my_bookings_page.dart';
import 'package:mvp_social_quest/screens/favorites/favorites_page.dart';
import 'package:mvp_social_quest/screens/profile/profile_page.dart';

/// 🏠 Page d’accueil avec navigation par BottomNavigationBar.
///   - Si l’utilisateur est commerçant, affiche son dashboard et son profil.
///   - Sinon, affiche Explorer, Réservations, Favoris et Profil.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isMerchant = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _determineUserType();
  }

  /// Récupère le type de l’utilisateur depuis /users/{uid}.type
  Future<void> _determineUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // pas connecté → profil invité
      setState(() => _loading = false);
      return;
    }
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final type = doc.data()?['type'] as String? ?? 'user';
    setState(() {
      _isMerchant = (type == 'merchant');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Loader global
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Liste des pages et items selon le rôle
    final pages =
        _isMerchant
            ? [const MerchantDashboardHome(), const ProfilePage()]
            : [
              const PartnersListPage(),
              const MyBookingsPage(),
              const FavoritesPage(),
              const ProfilePage(),
            ];

    final items =
        _isMerchant
            ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ]
            : const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explorer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Réservations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoris',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: items,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
