// lib/widgets/forms/partner_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/partner_controller.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/partner.dart';
import '../../../core/utils/form_validators.dart';
import '../common/async_value_widget.dart';
import '../common/primary_button.dart';

class PartnerForm extends ConsumerStatefulWidget {
  final Partner? initial;
  final void Function()? onSaved;

  const PartnerForm({super.key, this.initial, this.onSaved});

  @override
  ConsumerState<PartnerForm> createState() => _PartnerFormState();
}

class _PartnerFormState extends ConsumerState<PartnerForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _address;
  late TextEditingController _phone;
  late String _category;

  // Liste des catégories disponibles
  static const List<String> _categories = [
    'Sport',
    'Culture',
    'Bien être',
    'Restaurant',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _desc = TextEditingController(text: widget.initial?.description ?? '');
    _address = TextEditingController(text: widget.initial?.address ?? '');
    _phone = TextEditingController(text: widget.initial?.phone ?? '');
    // Initialisation de la catégorie
    _category =
        widget.initial?.category?.isNotEmpty == true &&
                _categories.contains(widget.initial!.category)
            ? widget.initial!.category
            : _categories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    final newPartner = Partner(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      description: _desc.text.trim(),
      address: _address.text.trim(),
      category: _category,
      latitude: widget.initial?.latitude ?? 0.0,
      longitude: widget.initial?.longitude ?? 0.0,
      ownerId: widget.initial?.ownerId ?? user.uid,
      phone: _phone.text.trim(),
      photos: widget.initial?.photos ?? [],
      avgRating: widget.initial?.avgRating,
      reviewsCount: widget.initial?.reviewsCount,
      geohash: widget.initial?.geohash,
      active: widget.initial?.active ?? true,
      slots: widget.initial?.slots ?? {},
      maxReduction: widget.initial?.maxReduction,
    );

    ref.read(partnerControllerProvider.notifier).save(newPartner).then((_) {
      widget.onSaved?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partnerControllerProvider);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom de l’activité'),
            validator: FormValidators.required(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Adresse'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Catégorie'),
            items:
                _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (val) => setState(() => _category = val!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          AsyncValueWidget(
            value: state,
            dataBuilder:
                (_) => PrimaryButton(
                  text: widget.initial == null ? 'Créer' : 'Mettre à jour',
                  onPressed: _submit,
                ),
          ),
        ],
      ),
    );
  }
}
