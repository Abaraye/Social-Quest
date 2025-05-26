import 'package:flutter/material.dart';

class UserNavItem {
  const UserNavItem(this.icon, this.label, this.path);
  final IconData icon;
  final String label;
  final String path;
}

/// ordre = index dans la bottom-bar
const userNavItems = [
  UserNavItem(Icons.explore, 'Explorer', '/home'),
  UserNavItem(Icons.event, 'Réservations', '/home/bookings'),
  UserNavItem(Icons.favorite, 'Favoris', '/home/favorites'),
  UserNavItem(Icons.person, 'Profil', '/home/profile'),
];

/// renvoie l’index du bouton qui correspond au `location` courant
int indexFromPath(String location) {
  int best = 0; // index retenu
  int bestLen = 0; // longueur du path retenu

  for (var i = 0; i < userNavItems.length; i++) {
    final p = userNavItems[i].path;
    if (location == '/' && p == '/') return 0; // page d’accueil
    if (location.startsWith(p) && p.length > bestLen) {
      best = i;
      bestLen = p.length;
    }
  }
  return best;
}
