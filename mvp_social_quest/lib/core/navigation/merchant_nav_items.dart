// lib/core/navigation/merchant_nav_items.dart
import 'package:flutter/material.dart';

class MerchantNavItem {
  const MerchantNavItem(this.icon, this.label, this.buildPath);
  final IconData icon;
  final String label;
  final String Function(String partnerId) buildPath;
}

final merchantNavItems = [
  // ⇣ ajoute le préfixe dashboard/ + pid
  MerchantNavItem(Icons.dashboard, 'Dashboard', (pid) => '/dashboard/$pid'),
  MerchantNavItem(
    Icons.event,
    'Réservations',
    (pid) => '/dashboard/$pid/bookings',
  ),
  MerchantNavItem(Icons.person, 'Profil', (pid) => '/dashboard/$pid/profile'),
];

int indexFromPath(String pid, String location) {
  int best = 0;
  int bestLen = 0;
  for (var i = 0; i < merchantNavItems.length; i++) {
    final p = merchantNavItems[i].buildPath(pid);
    if (location.startsWith(p) && p.length > bestLen) {
      best = i;
      bestLen = p.length;
    }
  }
  return best;
}
