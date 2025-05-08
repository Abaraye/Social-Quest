import 'dart:async';
import '../../../models/partner.dart';

/// Stub très simple – sera remplacé par un Repository au Sprint 2.
class PartnerService {
  static Stream<List<Partner>> streamPartners() =>
      Stream<List<Partner>>.value(const []);
}
