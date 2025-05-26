// Ajoutez dans lib/core/providers/service_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/services/booking_service.dart';
import 'package:mvp_social_quest/services/favorite_service.dart';
import 'package:mvp_social_quest/services/firebase_storage_service.dart';
import 'package:mvp_social_quest/services/storage_service.dart';

/// Provider pour [StorageService]
final storageServiceProvider = Provider<StorageService>(
  (ref) => FirebaseStorageService.instance,
);

final bookingServiceProvider = Provider(
  (ref) => BookingService(FirebaseFirestore.instance),
);

final favoriteServiceProvider = Provider(
  (ref) => FavoriteService(FirebaseFirestore.instance),
);
