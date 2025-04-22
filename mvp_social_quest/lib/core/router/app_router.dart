// =============================================================
// lib/core/app_router.dart – v1.4
// =============================================================
// ✅ Routeur centralisé avec support des pages dynamiques
// 📌 Gère les routes : /dashboard, /manage/:id, /bookings/:id, /slots/:id, /fill-rate/:id
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../screens/bookings/partner_bookings_page.dart';
import '../../screens/partners/manage_partner_page.dart';
import '../../screens/partners/manage_partner_slots_page.dart';
import '../../screens/partners/merchant_dashboard_home.dart';
import '../../screens/partners/fillrate_detail_page.dart'; // ✅ Assure-toi que ce chemin est correct

Route<dynamic> generateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '');
  final pathSegments = uri.pathSegments;

  // 👋 Page par défaut (ex : /)
  if (pathSegments.isEmpty) {
    return MaterialPageRoute(builder: (_) => const MerchantDashboardHome());
  }

  // ✅ Exemple : /dashboard
  if (uri.path == '/dashboard') {
    return MaterialPageRoute(builder: (_) => const MerchantDashboardHome());
  }

  // 🧩 Exemple : /manage/<partnerId>
  if (pathSegments.length == 2 && pathSegments[0] == 'manage') {
    final partnerId = pathSegments[1];
    return MaterialPageRoute(
      builder: (_) => ManagePartnerPage(partnerId: partnerId),
    );
  }

  // 📆 Exemple : /bookings/<partnerId>
  if (pathSegments.length == 2 && pathSegments[0] == 'bookings') {
    final partnerId = pathSegments[1];
    return MaterialPageRoute(
      builder: (_) => PartnerBookingsPage(partnerId: partnerId),
    );
  }

  // 🗓️ Exemple : /slots/<partnerId>
  if (pathSegments.length == 2 && pathSegments[0] == 'slots') {
    final partnerId = pathSegments[1];
    return MaterialPageRoute(
      builder: (_) => ManagePartnerSlotsPage(partnerId: partnerId),
    );
  }

  // 📊 Exemple : /fill-rate/<partnerId>
  if (pathSegments.length == 2 && pathSegments[0] == 'fill-rate') {
    final partnerId = pathSegments[1];
    return MaterialPageRoute(
      builder: (_) => FillRateDetailPage(partnerId: partnerId),
    );
  }

  // 🚫 Route non trouvée
  return MaterialPageRoute(
    builder:
        (_) => const Scaffold(
          body: Center(
            child: Text("Page non trouvée", style: TextStyle(fontSize: 16)),
          ),
        ),
  );
}
