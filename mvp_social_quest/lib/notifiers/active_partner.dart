// lib/notifiers/active_partner_notifier.dart
import 'package:flutter/foundation.dart';

/// ChangeNotifier pour centraliser l'état du partner courant.
class ActivePartnerNotifier extends ChangeNotifier {
  String? _partnerId;
  String? get partnerId => _partnerId;

  set partnerId(String? id) {
    if (_partnerId != id) {
      _partnerId = id;
      notifyListeners();
    }
  }
}
