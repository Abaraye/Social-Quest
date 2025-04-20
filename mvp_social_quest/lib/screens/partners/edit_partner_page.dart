// lib/screens/partners/edit_partner_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/partners/manage/slot_form.dart';
import '../../widgets/partners/manage/slot_list.dart';

/// ✨ Page de gestion d'une activité existante (commerçant)
/// Permet d'ajouter des créneaux, voir les réductions associées et les modifier/supprimer.
class EditPartnerPage extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  const EditPartnerPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<EditPartnerPage> createState() => _EditPartnerPageState();
}

class _EditPartnerPageState extends State<EditPartnerPage> {
  DateTime? selectedDateTime;
  final reductionAmountController = TextEditingController();
  final groupSizeController = TextEditingController();

  List<Map<String, dynamic>> slots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  /// 🔄 Charge les créneaux depuis Firestore
  Future<void> _loadSlots() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('partners')
            .doc(widget.partnerId)
            .collection('slots')
            .orderBy('startTime')
            .get();

    if (mounted) {
      setState(() {
        slots =
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
        isLoading = false;
      });
    }
  }

  /// 🗓 Ouvre un sélecteur date + heure
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// ➕ Ajoute un nouveau créneau avec une réduction par défaut
  Future<void> _addSlot() async {
    if (selectedDateTime == null) return;

    final amount = int.tryParse(reductionAmountController.text.trim());
    final groupSize = int.tryParse(groupSizeController.text.trim());
    if (amount == null || groupSize == null) return;

    final slotData = {
      'startTime': Timestamp.fromDate(selectedDateTime!),
      'reductions': [
        {'amount': amount, 'groupSize': groupSize},
      ],
    };

    final docRef = await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.partnerId)
        .collection('slots')
        .add(slotData);

    setState(() {
      slots.add({...slotData, 'id': docRef.id});
      selectedDateTime = null;
      reductionAmountController.clear();
      groupSizeController.clear();
    });
  }

  /// 🌐 Interface principale : formulaire + liste des slots
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gérer ${widget.partnerName}"),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManagePartnerSlotForm(
                      selectedDateTime: selectedDateTime,
                      reductionAmountController: reductionAmountController,
                      groupSizeController: groupSizeController,
                      onPickDateTime: _pickDateTime,
                      onAddSlot: _addSlot,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ManagePartnerSlotList(
                        slots: slots,
                        partnerId: widget.partnerId,
                        onSlotsUpdated:
                            (updated) => setState(() => slots = updated),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
