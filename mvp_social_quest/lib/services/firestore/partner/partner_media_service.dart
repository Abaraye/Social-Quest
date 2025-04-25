import 'package:cloud_firestore/cloud_firestore.dart';

/// Gestion des photos & assets d’un partenaire.
class PartnerMediaService {
  static final _firestore = FirebaseFirestore.instance;

  /// Ajoute une URL de photo à la collection du partenaire.
  static Future<void> addPhoto(String partnerId, String photoUrl) =>
      _firestore.collection('partners').doc(partnerId).update({
        'photos': FieldValue.arrayUnion([photoUrl]),
      });

  /// Retire une URL de photo.
  static Future<void> removePhoto(String partnerId, String photoUrl) =>
      _firestore.collection('partners').doc(partnerId).update({
        'photos': FieldValue.arrayRemove([photoUrl]),
      });
}
