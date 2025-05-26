// lib/data/crud_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// CRUD minimaliste pour Firestore (un sous-coll /collection-racine par repo).
abstract class CrudRepository<T> {
  /// Chemin absolu ou fonction de chemin dynamique, suivant ton besoin.
  CollectionReference<Map<String, dynamic>> collection();

  /// ↻  Toutes les entrées, live.
  Stream<List<T>> watchAll();

  /// 1 élément par id (lecture ponctuelle).
  Future<T?> fetch(String id);

  /// Création / mise à jour (merge true).
  Future<void> save(T value);

  /// Suppression brutale.
  Future<void> delete(String id);
}
