import 'package:flutter/material.dart';
import 'package:mvp_social_quest/widgets/partners/slots/slots_calendar.dart';

/// Section “Gérer mes créneaux” dans le dashboard marchand.
/// Délègue la gestion des créneaux au widget [SlotsCalendar] en mode `manage`.
///
/// 💡 Suggestions :
///  • Si vous en avez besoin, exposez un callback `onSlotsChanged` vers le container parent
///  • Ajouter un loader ou placeholder si le calendrier met du temps à s’initialiser
class ManagePartnerSlotsSection extends StatelessWidget {
  final String partnerId;

  const ManagePartnerSlotsSection({Key? key, required this.partnerId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlotsCalendar(
      partnerId: partnerId,
      mode: SlotsCalendarMode.manage,
      onSlotAdded: () {
        // 📌 Vous pouvez propager cet événement pour rafraîchir d'autres sections
      },
    );
  }
}
