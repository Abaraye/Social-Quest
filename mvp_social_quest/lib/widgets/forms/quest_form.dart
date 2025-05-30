import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvp_social_quest/core/providers/service_provider.dart';
import 'package:mvp_social_quest/models/quest_category.dart';
import 'package:mvp_social_quest/services/storage_service.dart';
import 'package:path/path.dart' as path;

import '../../../models/quest.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/providers/repository_providers.dart';
import '../../widgets/quest_photo_picker.dart';

class QuestForm extends ConsumerStatefulWidget {
  final String partnerId;
  final Quest? initial;
  final void Function(Quest quest) onSubmit;

  const QuestForm({
    Key? key,
    required this.partnerId,
    required this.onSubmit,
    this.initial,
  }) : super(key: key);

  @override
  ConsumerState<QuestForm> createState() => _QuestFormState();
}

class _QuestFormState extends ConsumerState<QuestForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _price;
  late TextEditingController _capacity;
  DateTime? _startDate;
  DateTime? _endDate;

  final ImagePicker _picker = ImagePicker();
  List<String> _photoUrls = [];
  List<XFile> _newPhotos = [];
  bool _loading = false;
  late final StorageService _storage;

  late QuestCategory _category;

  @override
  void initState() {
    super.initState();
    _storage = ref.read(storageServiceProvider);
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _desc = TextEditingController(text: widget.initial?.description ?? '');
    _price = TextEditingController(
      text:
          widget.initial != null
              ? (widget.initial!.priceCents / 100).toStringAsFixed(2)
              : '',
    );
    _capacity = TextEditingController(
      text: widget.initial?.capacity.toString() ?? '',
    );
    _startDate = widget.initial?.startsAt;
    _endDate = widget.initial?.endsAt;
    _photoUrls = List.from(widget.initial?.photos ?? []);
    _category = widget.initial?.category ?? QuestCategory.sport;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() => _newPhotos.addAll(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final priceCents = (double.tryParse(_price.text.trim()) ?? 0) * 100;
      final oldPhotoUrls = widget.initial?.photos ?? [];

      var quest = Quest(
        id: widget.initial?.id ?? '',
        partnerId: widget.partnerId,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        priceCents: priceCents.toInt(),
        currency: 'EUR',
        photos: List.from(_photoUrls),
        capacity: int.tryParse(_capacity.text.trim()) ?? 0,
        bookedCount: widget.initial?.bookedCount ?? 0,
        startsAt: _startDate,
        endsAt: _endDate,
        avgRating: widget.initial?.avgRating ?? 0,
        reviewsCount: widget.initial?.reviewsCount ?? 0,
        isActive: widget.initial?.isActive ?? true,
        createdAt: widget.initial?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        category: _category,
      );

      final repo = ref.read(questRepoProvider);
      final questId = await repo.saveQuest(quest);
      quest = quest.copyWith(id: questId);

      final allUrls = List<String>.from(_photoUrls);

      for (final picked in _newPhotos) {
        final file = File(picked.path);
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        try {
          final url = await _storage.upload('quests/$questId', file, fileName);
          allUrls.add(url);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec upload ${picked.name}: $e')),
          );
        }
      }

      final deletedUrls = oldPhotoUrls.where((url) => !allUrls.contains(url));
      for (final url in deletedUrls) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        } catch (e) {
          debugPrint('Erreur suppression image Firebase Storage: $e');
        }
      }

      await repo.updateQuestPhotos(questId, allUrls);

      setState(() {
        _photoUrls = allUrls;
        _newPhotos.clear();
      });

      widget.onSubmit(quest.copyWith(id: questId, photos: allUrls));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestPhotoPicker(
            networkImages: _photoUrls,
            localImages: _newPhotos,
            onPick: _pickImages,
            onRemoveNetwork: (url) => setState(() => _photoUrls.remove(url)),
            onRemoveLocal: (file) => setState(() => _newPhotos.remove(file)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Titre'),
            validator: FormValidators.required(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<QuestCategory>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Catégorie'),
            items:
                QuestCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.label));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _category = value);
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child:
                _loading
                    ? const CircularProgressIndicator()
                    : Text(widget.initial == null ? 'Créer' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }
}
