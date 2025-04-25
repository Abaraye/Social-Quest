import 'package:flutter/foundation.dart';
import '../models/partner/partner.dart';
import '../services/firestore/partner/partner_service.dart';

/// ChangeNotifier to centralize the "current" Partner throughout the app.
class PartnerProvider extends ChangeNotifier {
  Partner? _selectedPartner;

  Partner? get selectedPartner => _selectedPartner;
  String? get selectedPartnerId => _selectedPartner?.id;

  /// Load and select a partner by its ID.
  Future<void> selectPartnerById(String partnerId) async {
    try {
      final partner = await PartnerService.getPartnerById(partnerId);
      _selectedPartner = partner;
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ PartnerProvider: failed to load partner $partnerId: $e');
      rethrow;
    }
  }

  /// Optionally clear the current selection
  void clearSelection() {
    _selectedPartner = null;
    notifyListeners();
  }
}
