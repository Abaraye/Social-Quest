// lib/core/services/storage_service.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

/// Abstraction du service de stockage pour l'upload de fichiers
class StorageService {
  Future<String> upload(String dir, File file, String baseName) async {
    final ext = p.extension(file.path); // « .jpg » par ex.
    final ref = FirebaseStorage.instance.ref().child(
      '$dir/$baseName$ext',
    ); // chemin COMPLET
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
