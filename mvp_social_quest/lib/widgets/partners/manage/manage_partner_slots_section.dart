import 'package:flutter/material.dart';
import 'package:mvp_social_quest/widgets/partners/slots/slots_calendar.dart';

/// Section « Gestion des créneaux » pour le dashboard commerçant.
class ManagePartnerSlotsSection extends StatelessWidget {
  final String partnerId;
  const ManagePartnerSlotsSection({Key? key, required this.partnerId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlotsCalendar(
      partnerId: partnerId,
      mode: SlotsCalendarMode.manage,
      onSlotAdded:
          () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Créneau ajouté'))),
    );
  }
}
