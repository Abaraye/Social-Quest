import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../partners/manage_partner_page.dart'; // Activités
import '../partners/merchant_dashboard_home.dart'; // Dashboard (wrapper)
import '../profile/profile_page.dart';
import '../partners/partners_list_page.dart';
import '../favorites/favorites_page.dart';
import '../bookings/my_bookings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  String? _type;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchType();
  }

  Future<void> _fetchType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    setState(() {
      _type = doc.data()?['type'] ?? 'user';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final merchant = _type == 'merchant';

    // pages ---------------------------------------------------------------
    final pages =
        merchant
            ? [
              const ManagePartnerPage(), // 0 Activités
              const MerchantDashboardHome(), // 1 Dashboard
              const ProfilePage(), // 2 Profil
            ]
            : [
              const PartnersListPage(),
              const MyBookingsPage(),
              const FavoritesPage(),
              const ProfilePage(),
            ];

    // items ---------------------------------------------------------------
    final items =
        merchant
            ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront),
                label: 'Activités',
              ),
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
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
