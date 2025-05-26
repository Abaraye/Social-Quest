// lib/widgets/forms/slot_form.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/slot.dart';
import '../../../models/discount.dart';
import '../../../core/state/slot_controller.dart';
import '../../../core/providers/discount_repository_provider.dart';
import '../../../core/providers/repository_providers.dart';

/// Wrapper temporaire pour gérer l'ID des réductions en édition
class DiscountTemp {
  final String? id;
  final DiscountType type;
  final Map<String, dynamic> details;

  DiscountTemp({this.id, required this.type, required this.details});

  Discount toDiscount() {
    return Discount(
      id: id ?? '',
      type: type,
      details: details,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    switch (type) {
      case DiscountType.group:
        return "Groupe : ${details['percent']}% dès ${details['minPeople']} pers.";
      case DiscountType.lastMinute:
        return "Last Minute : ${details['percent']}% à H-${details['minutesBefore']}";
      case DiscountType.challenge:
        return "Challenge : ${details['label'] ?? 'Défi'}";
    }
  }
}

class SlotForm extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final String questId;
  final Slot? slotToEdit;

  const SlotForm({
    super.key,
    required this.initialDate,
    required this.questId,
    this.slotToEdit,
  });

  @override
  ConsumerState<SlotForm> createState() => _SlotFormState();
}

class _SlotFormState extends ConsumerState<SlotForm> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _capacity;
  late TextEditingController _priceCtrl;
  String _currency = 'EUR';
  final List<DiscountTemp> _discounts = [];
  Set<String> _originalDiscountIds = {};
  StreamSubscription<List<Discount>>? _discountsSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.slotToEdit != null) {
      final editing = widget.slotToEdit!;
      _startTime = TimeOfDay.fromDateTime(editing.startTime);
      _endTime = TimeOfDay.fromDateTime(
        editing.startTime.add(Duration(minutes: editing.duration)),
      );
      _capacity = editing.capacity;
      _priceCtrl = TextEditingController(
        text: (editing.priceCents / 100).toStringAsFixed(2),
      );
      _currency = editing.currency;

      // Écoute réactive des réductions
      _discountsSubscription = ref
          .read(discountRepositoryProvider)
          .watchAll(slotId: editing.id)
          .listen((existing) {
            setState(() {
              _originalDiscountIds = existing.map((d) => d.id).toSet();
              _discounts
                ..clear()
                ..addAll(
                  existing.map(
                    (d) => DiscountTemp(
                      id: d.id,
                      type: d.type,
                      details: Map<String, dynamic>.from(d.details),
                    ),
                  ),
                );
            });
          });
    } else {
      _startTime = const TimeOfDay(hour: 18, minute: 0);
      _endTime = const TimeOfDay(hour: 20, minute: 0);
      _capacity = 10;
      _priceCtrl = TextEditingController(text: '7');
    }
  }

  @override
  void dispose() {
    _discountsSubscription?.cancel();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<DiscountTemp?> _showDiscountDialog([DiscountTemp? toEdit]) {
    return showDialog<DiscountTemp>(
      context: context,
      builder: (ctx) {
        final isEditing = toEdit != null;
        DiscountType selectedType = toEdit?.type ?? DiscountType.group;
        final formKey = GlobalKey<FormState>();
        final data = Map<String, dynamic>.from(toEdit?.details ?? {});

        return AlertDialog(
          title: Text(
            isEditing ? 'Modifier une réduction' : 'Ajouter une réduction',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<DiscountType>(
                  value: selectedType,
                  onChanged: (v) => selectedType = v!,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items:
                      DiscountType.values
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)),
                          )
                          .toList(),
                ),
                const SizedBox(height: 12),
                if (selectedType == DiscountType.group) ...[
                  TextFormField(
                    initialValue: data['percent']?.toString(),
                    decoration: const InputDecoration(
                      labelText: '% de réduction',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => data['percent'] = int.tryParse(v),
                  ),
                  TextFormField(
                    initialValue: data['minPeople']?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Nombre minimum de personnes',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => data['minPeople'] = int.tryParse(v),
                  ),
                ] else if (selectedType == DiscountType.lastMinute) ...[
                  TextFormField(
                    initialValue: data['percent']?.toString(),
                    decoration: const InputDecoration(
                      labelText: '% de réduction',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => data['percent'] = int.tryParse(v),
                  ),
                  TextFormField(
                    initialValue: data['minutesBefore']?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Minutes avant le créneau',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => data['minutesBefore'] = int.tryParse(v),
                  ),
                ] else if (selectedType == DiscountType.challenge) ...[
                  TextFormField(
                    initialValue: data['label'] as String?,
                    decoration: const InputDecoration(
                      labelText: 'Description du défi',
                    ),
                    onChanged: (v) => data['label'] = v,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final temp = DiscountTemp(
                    id: toEdit?.id,
                    type: selectedType,
                    details: data,
                  );
                  Navigator.pop(ctx, temp);
                }
              },
              child: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDiscount() async {
    final newDiscount = await _showDiscountDialog();
    if (newDiscount != null) {
      setState(() => _discounts.add(newDiscount));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final startDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    final duration = endDate.difference(startDate).inMinutes;
    final priceCents =
        (double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0) * 100;

    final slotCtrl = ref.read(slotControllerProvider.notifier);
    final discountRepo = ref.read(discountRepositoryProvider);

    if (widget.slotToEdit != null) {
      final slotId = widget.slotToEdit!.id;
      final updatedSlot = widget.slotToEdit!.copyWith(
        startTime: startDate,
        duration: duration,
        capacity: _capacity,
        priceCents: priceCents.round(),
        currency: _currency,
        discountCount: _discounts.length,
      );
      await slotCtrl.save(updatedSlot);

      final currentIds =
          _discounts.where((d) => d.id != null).map((d) => d.id!).toSet();
      final toDelete = _originalDiscountIds.difference(currentIds);
      for (final id in toDelete) {
        await discountRepo.delete(slotId: slotId, discountId: id);
      }
      for (final d in _discounts) {
        await discountRepo.save(slotId: slotId, discount: d.toDiscount());
      }
    } else {
      final newSlot = Slot(
        id: '',
        questId: widget.questId,
        startTime: startDate,
        duration: duration,
        priceCents: priceCents.round(),
        reserved: false,
        currency: _currency,
        discountCount: _discounts.length,
        exceptions: const [],
        createdAt: DateTime.now(),
        capacity: _capacity,
      );
      final slotId = await slotCtrl.create(
        partnerId: widget.questId,
        questId: widget.questId,
        slot: newSlot,
      );
      for (final d in _discounts) {
        await discountRepo.save(slotId: slotId, discount: d.toDiscount());
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE d MMMM', 'fr_FR');

    if (widget.slotToEdit != null) {
      ref.watch(discountsProvider(widget.slotToEdit!.id)).whenData((list) {
        // On ne remplit qu'une seule fois, si _discounts est encore vide
        if (_discounts.isEmpty) {
          setState(() {
            _originalDiscountIds = list.map((d) => d.id).toSet();
            _discounts.addAll(
              list.map(
                (d) => DiscountTemp(
                  id: d.id,
                  type: d.type,
                  details: Map.from(d.details),
                ),
              ),
            );
          });
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.slotToEdit != null
                  ? 'Modifier créneau – ${df.format(widget.initialDate)}'
                  : 'Nouveau créneau – ${df.format(widget.initialDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Début : ${_startTime.format(context)}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (picked != null) setState(() => _startTime = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Fin : ${_endTime.format(context)}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (picked != null) setState(() => _endTime = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _capacity.toString(),
              decoration: const InputDecoration(labelText: 'Capacité'),
              keyboardType: TextInputType.number,
              onChanged: (val) => _capacity = int.tryParse(val) ?? _capacity,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Prix',
                prefixText: '€ ',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currency,
              onChanged: (val) => setState(() => _currency = val!),
              decoration: const InputDecoration(labelText: 'Devise'),
              items: const [
                DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Réductions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addDiscount,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            ..._discounts
                .map(
                  (d) => ListTile(
                    title: Text(d.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            // 1) Ouvre le dialogue
                            final edited = await _showDiscountDialog(d);
                            if (edited != null) {
                              final slotId = widget.slotToEdit!.id;
                              final repo = ref.read(discountRepositoryProvider);

                              // 2) Persiste la modification en Firestore
                              await repo.save(
                                slotId: slotId,
                                discount: edited.toDiscount(),
                              );

                              // 3) Met à jour la liste affichée
                              setState(() {
                                final idx = _discounts.indexOf(d);
                                _discounts[idx] = edited;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final slotId = widget.slotToEdit!.id;
                            final repo = ref.read(discountRepositoryProvider);

                            // 1) Supprime dans Firestore
                            await repo.delete(
                              slotId: slotId,
                              discountId: d.id!,
                            );

                            // 2) Met à jour la liste affichée
                            setState(() {
                              _discounts.remove(d);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(widget.slotToEdit != null ? 'Enregistrer' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
