import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/quest.dart';
import 'crud_repository.dart';

class QuestRepository implements CrudRepository<Quest> {
  QuestRepository._();
  static final instance = QuestRepository._();
  final _col = FirebaseFirestore.instance.collection('quests');

  @override
  CollectionReference<Map<String, dynamic>> collection() => _col;

  @override
  Stream<List<Quest>> watchAll() =>
      _col.snapshots().map((snapshot) => snapshot.docs.map(_f).toList());

  @override
  Future<Quest?> fetch(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? _f(doc) : null;
  }

  @override
  Future<void> save(Quest q) =>
      _col.doc(q.id).set(q.toJson(), SetOptions(merge: true));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  Quest _f(DocumentSnapshot<Map<String, dynamic>> d) =>
      Quest.fromJson({'id': d.id, ...?d.data()});

  /// Crée ou met à jour une quête. Retourne l'ID.
  Future<String> saveQuest(Quest quest) async {
    if (quest.id.isEmpty) {
      final docRef = _col.doc();
      await docRef.set(quest.copyWith(id: docRef.id).toJson());
      return docRef.id;
    } else {
      await _col.doc(quest.id).set(quest.toJson(), SetOptions(merge: true));
      return quest.id;
    }
  }

  /// Upload une photo dans Storage et renvoie l'URL publique
  Future<String> uploadPhoto(String questId, File file) async {
    final fileName = file.uri.pathSegments.last;
    final refPath = 'quests/$questId/$fileName';
    final ref = FirebaseStorage.instance.ref().child(refPath);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  /// Met à jour la liste des URLs de photos de la quête
  /// Supprime les images qui ne sont plus référencées
  Future<void> updateQuestPhotos(String questId, List<String> newUrls) async {
    final oldQuest = await fetch(questId);
    final oldUrls = oldQuest?.photos ?? [];

    // Identifie les images supprimées par l'utilisateur
    final deletedUrls = oldUrls.where((url) => !newUrls.contains(url));

    for (final url in deletedUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        // Peut arriver si le fichier n'existe plus ou si URL incorrecte
        print('Erreur suppression image: $e');
      }
    }

    await _col.doc(questId).update({
      'photos': newUrls,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Supprime une quête et toutes ses images associées
  Future<void> deleteQuestWithPhotos(Quest quest) async {
    // Supprimer les images
    for (final url in quest.photos) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        print('Erreur suppression image: $e');
      }
    }

    // Supprimer le document Firestore
    await _col.doc(quest.id).delete();
  }
}
