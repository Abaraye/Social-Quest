// Ajoutez dans lib/core/providers/service_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/services/firebase_storage_service.dart';
import 'package:mvp_social_quest/services/storage_service.dart';

/// Provider pour [StorageService]
final storageServiceProvider = Provider<StorageService>(
  (ref) => FirebaseStorageService.instance,
);
