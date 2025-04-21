import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mvp_social_quest/screens/partners/partners_list_page.dart';
import 'package:mvp_social_quest/screens/favorites/favorites_page.dart';
import 'package:mvp_social_quest/screens/home/profile_page.dart';
import 'package:mvp_social_quest/screens/partners/manage_partner_page.dart';
import 'package:mvp_social_quest/screens/bookings/my_bookings_page.dart'; // ✅ Nouveau

/// 🏠 Page principale avec navigation conditionnelle selon le rôle (user / merchant)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _userType;
  bool _isLoading = true;

  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserType();
  }

  /// 🔄 Récupération du type d'utilisateur
  Future<void> _fetchUserType() async {
    if (_user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.uid)
            .get();

    setState(() {
      _userType = doc.data()?['type'] ?? 'user';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isMerchant = _userType == 'merchant';

    /// 🧭 Pages à afficher dans les onglets
    final pages =
        isMerchant
            ? [const ManagePartnerPage(), const ProfilePage()]
            : [
              const PartnersListPage(),
              const MyBookingsPage(), // 🆕 Page Mes réservations
              const FavoritesPage(),
              const ProfilePage(),
            ];

    /// 🔘 Items de la BottomNavigationBar
    final items =
        isMerchant
            ? [
              const BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Mon activité',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ]
            : [
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explorer',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Réservations',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoris',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: items,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
