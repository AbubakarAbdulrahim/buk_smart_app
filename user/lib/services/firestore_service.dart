import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/incident.dart';
import '../models/lost_found_item.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  static const _maxUploadBytes = 2 * 1024 * 1024;

  Future<String?> uploadImage(XFile file, String folder) async {
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > _maxUploadBytes) {
      throw Exception('Image is too large. Please choose an image below 2MB.');
    }
    final ref = _storage.ref('$folder/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  Future<void> createIncident(Incident incident) async {
    await _db.collection('incidents').add({
      ...incident.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createLostFound(LostFoundItem item) async {
    await _db.collection('lost_found').add({
      ...item.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureUserProfile({
    required String uid,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Incident>> myIncidents(String uid) {
    return _db
        .collection('incidents')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Incident.fromMap(d.id, d.data())).toList());
  }

  Stream<List<LostFoundItem>> lostFound(String type) {
    return _db
        .collection('lost_found')
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LostFoundItem.fromMap(d.id, d.data())).toList());
  }

  Stream<List<LostFoundItem>> myLostFound(String uid) {
    return _db
        .collection('lost_found')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LostFoundItem.fromMap(d.id, d.data())).toList());
  }
}
