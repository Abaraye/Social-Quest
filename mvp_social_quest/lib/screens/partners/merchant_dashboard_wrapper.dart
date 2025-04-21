// =============================================================
// lib/screens/partners/merchant_dashboard_wrapper.dart – v1.1
// =============================================================
// 🧭 Wrapper du dashboard commerçant après création d'activité
// ✅ Corrige l’erreur de typage sur la liste des partenaires
// -------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'merchant_dashboard_page.dart';

class MerchantDashboardWrapper extends StatefulWidget {
  const MerchantDashboardWrapper({super.key});

  @override
  State<MerchantDashboardWrapper> createState() =>
      _MerchantDashboardWrapperState();
}

class _MerchantDashboardWrapperState extends State<MerchantDashboardWrapper> {
  bool _isLoading = true;
  List<Map<String, String>> _partners = [];
  Map<String, dynamic>? _firstPartnerData;

  @override
  void initState() {
    super.initState();
    _loadPartner();
  }

  Future<void> _loadPartner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap =
        await FirebaseFirestore.instance
            .collection('partners')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

    if (!mounted) return;

    if (snap.docs.isNotEmpty) {
      final partner = snap.docs.first;
      setState(() {
        _partners =
            snap.docs.map((doc) {
              final data = doc.data();
              return {'id': doc.id, 'name': data['name']?.toString() ?? ''};
            }).toList();
        _firstPartnerData = partner.data();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_firstPartnerData == null) {
      return const Scaffold(
        body: Center(child: Text("Aucune activité trouvée")),
      );
    }

    final partnerId = _partners.first['id'];
    final partnerName = _firstPartnerData!['name']?.toString() ?? '';

    return MerchantDashboardPage(
      partnerId: partnerId,
      partnerName: partnerName,
      bookingsByDay: {},
      fillRate: 0.0,
      avgRating: 0.0,
      allPartners: _partners,
      onPartnerSelected: (id) {
        // Logique future si tu veux changer de dashboard selon partenaire
      },
    );
  }
}
