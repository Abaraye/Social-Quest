// lib/core/app_router.dart – v1.5
// =============================================================
// ✅ Routeur centralisé avec support des pages dynamiques
// 📌 Gère les routes : /, /dashboard, /manage/:id, /bookings/:id, /slots/:id, /fill-rate/:id
// -------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/screens/partners/merchant_dashboard_home.dart';
import 'package:mvp_social_quest/screens/partners/manage_partner_page.dart';
import 'package:mvp_social_quest/screens/partners/manage_partner_slots_page.dart';
import 'package:mvp_social_quest/screens/bookings/partner_bookings_page.dart';
import 'package:mvp_social_quest/screens/partners/fill_rate_detail_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '');
  final segments = uri.pathSegments;

  // Racine ou /dashboard → dashboard marchand
  if (segments.isEmpty || uri.path == '/dashboard') {
    return MaterialPageRoute(builder: (_) => const MerchantDashboardHome());
  }

  // /manage/:partnerId → création/édition d'activité
  if (segments.length == 2 && segments[0] == 'manage') {
    final partnerId = segments[1];
    return MaterialPageRoute(
      builder: (_) => ManagePartnerPage(partnerId: partnerId),
    );
  }

  // /bookings/:partnerId → réservations du commerçant
  if (segments.length == 2 && segments[0] == 'bookings') {
    final partnerId = segments[1];
    return MaterialPageRoute(
      builder: (_) => PartnerBookingsPage(partnerId: partnerId),
    );
  }

  // /slots/:partnerId → gestion des créneaux
  if (segments.length == 2 && segments[0] == 'slots') {
    final partnerId = segments[1];
    return MaterialPageRoute(
      builder: (_) => ManagePartnerSlotsPage(partnerId: partnerId),
    );
  }

  // /fill-rate/:partnerId → détails du taux de remplissage
  if (segments.length == 2 && segments[0] == 'fill-rate') {
    final partnerId = segments[1];
    return MaterialPageRoute(
      builder: (_) => FillRateDetailPage(partnerId: partnerId),
    );
  }

  // Route inconnue → page 404 simple
  return MaterialPageRoute(
    builder:
        (_) => const Scaffold(
          body: Center(
            child: Text('Page non trouvée', style: TextStyle(fontSize: 16)),
          ),
        ),
  );
}
