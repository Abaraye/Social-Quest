import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/validators.dart'; // 🆕 petit helper (cf. note)
import '../../../models/reduction.dart';
import '../../../models/slot.dart';
import '../../../services/firestore/slot_service.dart';

/// ──────────────────────────────────────────────────────────────
/// Formulaire CRUD d’un créneau (template ou one-off) pour merchant.
/// ──────────────────────────────────────────────────────────────
class SlotForm extends StatefulWidget {
  final String partnerId;
  final DateTime initialDay; // pré-rempli par le calendrier
  final void Function()? onSaved; // callback après succès
  final Slot? slot; // null = création, sinon édition

  const SlotForm({
    super.key,
    required this.partnerId,
    required this.initialDay,
    this.onSaved,
    this.slot,
  });

  @override
  State<SlotForm> createState() => _SlotFormState();
}

class _SlotFormState extends State<SlotForm> {
  final _formKey = GlobalKey<FormState>();

  // ----- Controllers & state
  TimeOfDay? _time;
  final _priceCtrl = TextEditingController();
  int? _reduction; // en %
  int? _groupSize;

  // ----- Helpers
  /// Format monétaire FR (19,99 €).
  final _priceFmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  @override
  void initState() {
    super.initState();
    if (widget.slot != null) {
      final s = widget.slot!;
      _time = TimeOfDay.fromDateTime(s.startTime);
      _priceCtrl.text = (s.priceCents / 100).toStringAsFixed(2);
      if (s.reductions.isNotEmpty) {
        _reduction = s.reductions.first.amount;
        _groupSize = s.reductions.first.groupSize;
      }
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  // ----- UI ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.slot == null ? 'Nouveau créneau' : 'Modifier créneau',
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- Date (readonly)
            ListTile(
              leading: const Icon(Icons.today),
              title: Text(
                DateFormat('EEEE d MMMM', 'fr_FR').format(widget.initialDay),
              ),
            ),

            // --- Heure
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(
                _time != null ? _time!.format(context) : 'Choisir l’heure',
              ),
              trailing: const Icon(Icons.edit),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),

            // --- Prix TTC ---------------------------------------------------
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Prix TTC (€)',
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,3}([.,]\d{0,2})?'),
                ),
              ],
              validator: (value) {
                final v = value?.replaceAll(',', '.');
                final price = double.tryParse(v ?? '');
                if (price == null) return 'Entrez un nombre';
                if (price < 1 || price > 999) {
                  return 'De 1 à 999 €';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // --- Option réduction simple -----------------------------------
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _reduction != null ? '$_reduction' : null,
                    decoration: const InputDecoration(
                      labelText: 'Réduction (%)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => _reduction = int.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _groupSize != null ? '$_groupSize' : null,
                    decoration: const InputDecoration(
                      labelText: 'Nb personnes',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => _groupSize = int.tryParse(v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- Submit -----------------------------------------------------
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  // ----- Actions -----------------------------------------------------------
  Future<void> _pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (res != null) setState(() => _time = res);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _time == null) return;

    // ------ Build DateTime & price
    final dt = DateTime(
      widget.initialDay.year,
      widget.initialDay.month,
      widget.initialDay.day,
      _time!.hour,
      _time!.minute,
    );
    final priceEuros = double.parse(_priceCtrl.text.replaceAll(',', '.'));
    final priceCents = (priceEuros * 100).round();

    // ------ Build Slot model
    final slot = Slot(
      id: widget.slot?.id ?? '',
      startTime: dt,
      duration: widget.slot?.duration ?? 60,
      priceCents: priceCents,
      currency: 'EUR',
      reductions:
          (_reduction != null && _groupSize != null)
              ? [Reduction(amount: _reduction!, groupSize: _groupSize!)]
              : const [],
      reserved: widget.slot?.reserved ?? false,
      recurrence: widget.slot?.recurrence,
      recurrenceGroupId: widget.slot?.recurrenceGroupId,
      exceptions: widget.slot?.exceptions ?? const [],
      createdAt: widget.slot?.createdAt,
    );

    // ------ Persist
    if (widget.slot == null) {
      await SlotService.addSlot(widget.partnerId, slot);
    } else {
      await SlotService.updateSlot(
        partnerId: widget.partnerId,
        slotId: widget.slot!.id,
        updates: slot.toMap(),
      );
    }

    // ------ Feedback & close
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Créneau ${widget.slot == null ? 'ajouté' : 'mis à jour'}',
          ),
        ),
      );
      Navigator.pop(context);
      widget.onSaved?.call();
    }
  }
}
