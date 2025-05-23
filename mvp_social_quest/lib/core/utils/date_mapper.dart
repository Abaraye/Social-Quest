import 'package:cloud_firestore/cloud_firestore.dart';

/// Convertit un Timestamp OU une String ISO en DateTime.
DateTime? toDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.parse(v);
  throw ArgumentError('Unsupported date type $v');
}

/// Convertit un DateTime (ou DateTime?) en Timestamp pour Firestore.
Timestamp? toTimestamp(DateTime? d) => d == null ? null : Timestamp.fromDate(d);
