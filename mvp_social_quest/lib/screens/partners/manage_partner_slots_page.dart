// =============================================================
// lib/screens/partners/manage_partner_slots_page.dart – v3.2
// =============================================================
// 📅 Interface complète de gestion des créneaux avec SlotCard
// ✅ Création unique ou récurrente, suppression simple ou groupée
// -------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvp_social_quest/services/firestore/slot_service.dart';
import 'package:mvp_social_quest/widgets/partners/manage/recurring_slot_form.dart';
import 'package:mvp_social_quest/widgets/partners/manage/slot_card.dart';

class ManagePartnerSlotsPage extends StatefulWidget {
  final String partnerId;

  const ManagePartnerSlotsPage({super.key, required this.partnerId});

  @override
  State<ManagePartnerSlotsPage> createState() => _ManagePartnerSlotsPageState();
}

class _ManagePartnerSlotsPageState extends State<ManagePartnerSlotsPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Duration _duration = const Duration(hours: 1);
  int? _reduction;
  int? _groupSize;

  String _recurrenceType = 'Aucune';
  DateTime? _endDate;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 18, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  Future<void> _createSlot() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) return;

    final start = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final data = {
      'startTime': Timestamp.fromDate(start),
      'duration': _duration.inMinutes,
      'createdAt': FieldValue.serverTimestamp(),
      'reductions':
          _reduction != null && _groupSize != null
              ? [
                {'amount': _reduction, 'groupSize': _groupSize},
              ]
              : [],
      if (_recurrenceType != 'Aucune')
        'recurrence': {
          'type': _recurrenceType,
          if (_endDate != null) 'endDate': Timestamp.fromDate(_endDate!),
        },
    };

    await SlotService.addSlot(widget.partnerId, data);

    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _reduction = null;
      _groupSize = null;
      _recurrenceType = 'Aucune';
      _endDate = null;
    });
  }

  Future<void> _deleteSlot(String slotId) async {
    await SlotService.deleteSlot(widget.partnerId, slotId);
  }

  Future<void> _deleteRecurrenceGroup(String recurrenceGroupId) async {
    await SlotService.deleteRecurrenceGroup(
      widget.partnerId,
      recurrenceGroupId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotsStream =
        FirebaseFirestore.instance
            .collection('partners')
            .doc(widget.partnerId)
            .collection('slots')
            .orderBy('startTime')
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gérer les créneaux"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _selectedDate == null || _selectedTime == null
                          ? 'Choisir date et heure'
                          : DateFormat('dd/MM/yyyy HH:mm').format(
                            DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            ),
                          ),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Réduction %'),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (v) => setState(() => _reduction = int.tryParse(v)),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Taille du groupe minimum',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (v) => setState(() => _groupSize = int.tryParse(v)),
                  ),
                  const SizedBox(height: 12),
                  RecurringSlotForm(
                    recurrenceType: _recurrenceType,
                    onRecurrenceChanged:
                        (type) => setState(() => _recurrenceType = type),
                    endDate: _endDate,
                    onEndDateChanged: (date) => setState(() => _endDate = date),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _createSlot,
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter le créneau"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: slotsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final slots = snapshot.data!.docs;

                  if (slots.isEmpty) {
                    return const Center(
                      child: Text("Aucun créneau pour l'instant"),
                    );
                  }

                  return ListView.builder(
                    itemCount: slots.length,
                    itemBuilder: (context, i) {
                      final slot = slots[i];
                      final data = slot.data() as Map<String, dynamic>;
                      final dt = (data['startTime'] as Timestamp).toDate();
                      final reductions = List<Map<String, dynamic>>.from(
                        data['reductions'] ?? [],
                      );
                      final recurrence =
                          data['recurrence'] as Map<String, dynamic>?;
                      final recurrenceGroupId = data['recurrenceGroupId'];

                      return SlotCard(
                        startTime: dt,
                        reductions: reductions,
                        recurrence: recurrence,
                        onDelete: () => _deleteSlot(slot.id),
                        onDeleteGroup:
                            recurrenceGroupId != null
                                ? () =>
                                    _deleteRecurrenceGroup(recurrenceGroupId)
                                : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
