// lib/screens/partners/manage_partner_slots_page.dart

import 'package:flutter/material.dart';
import 'package:mvp_social_quest/models/slot.dart';
import 'package:mvp_social_quest/widgets/partners/slots/slots_calendar.dart';

/// 🛠 Page de gestion des créneaux d’une activité (commerçant)
/// Recharge automatiquement le calendrier après ajout/suppression.
class ManagePartnerSlotsPage extends StatefulWidget {
  final String partnerId;
  const ManagePartnerSlotsPage({Key? key, required this.partnerId})
    : super(key: key);

  @override
  State<ManagePartnerSlotsPage> createState() => _ManagePartnerSlotsPageState();
}

class _ManagePartnerSlotsPageState extends State<ManagePartnerSlotsPage> {
  /// Flag incrémenté pour forcer la reconstruction du [SlotsCalendar].
  int _reloadFlag = 0;

  void _refreshCalendar() => setState(() => _reloadFlag++);

  /// Appelé lors du tap sur un slot en mode gestion.
  void _onSlotTap(Slot slot) {
    // TODO: Afficher un bottom sheet pour éditer ou supprimer le slot.
    // ex: showEditSlotSheet(context, slot, onDone: _refreshCalendar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les créneaux'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SlotsCalendar(
        key: ValueKey(_reloadFlag),
        partnerId: widget.partnerId,
        mode: SlotsCalendarMode.manage,
        onSlotTap: _onSlotTap,
        onSlotAdded: _refreshCalendar,
      ),
    );
  }
}
