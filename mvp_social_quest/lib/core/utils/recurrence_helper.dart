import 'package:cloud_firestore/cloud_firestore.dart';

/// Génère la liste des occurrences d’une récurrence en excluant les exceptions.
class RecurrenceHelper {
  /// - [recurrence] doit contenir au moins 'type' et optionnellement 'endDate': Timestamp.
  /// - [start] : date de la 1ʳᵉ occurrence.
  /// - [exceptions] : dates à ignorer.
  /// - [now] : date à partir de laquelle on considère les futures occurrences.
  static List<DateTime> generateOccurrences({
    required Map<String, dynamic> recurrence,
    required DateTime start,
    required DateTime now,
    List<DateTime> exceptions = const [],
  }) {
    final List<DateTime> occs = [];
    final type = recurrence['type'] as String;
    final endTs = recurrence['endDate'] as Timestamp?;
    final endDate = endTs?.toDate() ?? start;
    var current = start;

    while (!current.isAfter(endDate)) {
      final isAfterNow = current.isAfter(now);
      final isException = exceptions.any(
        (e) =>
            e.year == current.year &&
            e.month == current.month &&
            e.day == current.day,
      );

      if (isAfterNow && !isException) {
        occs.add(current);
      }

      // Incrément selon type
      switch (type) {
        case 'Tous les jours':
          current = current.add(const Duration(days: 1));
          break;
        case 'Chaque semaine':
        case 'Tous les lundis':
          current = current.add(const Duration(days: 7));
          break;
        default:
          // support minimal, on sort
          current = endDate.add(const Duration(days: 1));
      }
    }

    return occs;
  }
}
