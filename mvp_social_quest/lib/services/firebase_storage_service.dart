// lib/core/services/firebase_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';
import 'package:path/path.dart' as path;

/// Implémentation de [StorageService] utilisant Firebase Storage
class FirebaseStorageService implements StorageService {
  FirebaseStorageService._();
  static final instance = FirebaseStorageService._();
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  @override
  Future<String> upload(String folder, File file, String filename) async {
    // Si on a déjà une extension dans `filename`, on la conserve
    final hasExt = filename.contains(RegExp(r'\.\w+$'));
    final name = hasExt ? filename : '$filename${path.extension(file.path)}';

    // le fullPath correct
    final fullPath = '$folder/$name';

    final ref = FirebaseStorage.instance.ref().child(fullPath);
    final snap = await ref.putFile(file);
    return await snap.ref.getDownloadURL();
  }
}
