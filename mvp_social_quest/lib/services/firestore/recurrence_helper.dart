import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/slot.dart';

/// Helper pour “dérouler” et gérer la récurrence des créneaux.
class RecurrenceHelper {
  /// Étend un slot “template” en une liste d’occurrences entre start et endDate,
  /// en appliquant les exceptions.
  static List<Slot> expand(Slot template, {required DateTime now}) {
    final rec = template.recurrence;
    if (rec == null || rec['type'] == 'Aucune') {
      return template.startTime.isAfter(now) ? [template] : [];
    }

    final type = rec['type'] as String;
    final endDate =
        (rec['endDate'] as Timestamp?)?.toDate() ?? template.startTime;
    final exceptions = template.exceptions;
    var current = template.startTime;
    final occurrences = <Slot>[];

    while (!current.isAfter(endDate)) {
      final isException = exceptions.any(
        (e) =>
            e.year == current.year &&
            e.month == current.month &&
            e.day == current.day,
      );
      if (!isException && current.isAfter(now)) {
        occurrences.add(template.copyWith(startTime: current));
      }
      // incrémenter selon le type
      switch (type) {
        case 'Tous les jours':
          current = current.add(const Duration(days: 1));
          break;
        case 'Chaque semaine':
          current = current.add(const Duration(days: 7));
          break;
        default:
          // si type inconnu, on arrête
          current = endDate.add(const Duration(days: 1));
      }
    }
    return occurrences;
  }

  /// Génère une liste de dates entre [slotStart] et [endDate]
  /// selon le type de récurrence donné.
  static List<DateTime> generateOccurrences({
    required DateTime slotStart,
    required String type,
    required DateTime endDate,
  }) {
    final dates = <DateTime>[];
    var current = slotStart;
    while (!current.isAfter(endDate)) {
      dates.add(current);
      switch (type) {
        case 'Tous les jours':
          current = current.add(const Duration(days: 1));
          break;
        case 'Chaque semaine':
          current = current.add(const Duration(days: 7));
          break;
        default:
          // on sort de la boucle si le type n'est pas reconnu
          current = endDate.add(const Duration(days: 1));
      }
    }
    return dates;
  }
}
