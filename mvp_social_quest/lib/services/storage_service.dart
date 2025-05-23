// lib/core/services/storage_service.dart
import 'dart:io';

/// Abstraction du service de stockage pour l'upload de fichiers
abstract class StorageService {
  /// Upload un [file] dans le dossier [folder] avec le nom [filename]
  /// Retourne l'URL publique du fichier
  Future<String> upload(String folder, File file, String filename);
}
