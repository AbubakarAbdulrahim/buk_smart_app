import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/incident.dart';
import '../models/lost_found_item.dart';
import '../models/past_question.dart';
import 'cloudinary_service.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _cloudinary = CloudinaryService();
  static const _maxUploadBytes = 2 * 1024 * 1024;

  Future<String?> uploadImage(XFile file, String folder) async {
    try {
      final url = await _cloudinary.uploadImage(file: file);
      if (url == null || url.isEmpty) {
        throw Exception("Cloudinary returned empty secure URL.");
      }
      return url;
    } catch (e) {
      throw Exception("Cloudinary Upload Error: $e");
    }
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

  Future<void> toggleBookmark(String itemId, String userId) async {
    final docRef = _db.collection('lost_found').doc(itemId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      final List<dynamic> bookmarks = docSnap.data()?['bookmarkedBy'] ?? [];
      if (bookmarks.contains(userId)) {
        await docRef.update({
          'bookmarkedBy': FieldValue.arrayRemove([userId])
        });
      } else {
        await docRef.update({
          'bookmarkedBy': FieldValue.arrayUnion([userId])
        });
      }
    }
  }

  Stream<List<LostFoundItem>> bookmarkedLostFound(String userId) {
    return _db
        .collection('lost_found')
        .where('bookmarkedBy', arrayContains: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => LostFoundItem.fromMap(d.id, d.data())).toList());
  }

  Future<void> ensureUserProfile({
    required String uid,
    required String email,
    String? name,
    String? matricNumber,
    String? faculty,
    String? department,
    String? program,
    String? level,
    String? photoUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'matricNumber': matricNumber,
      'faculty': faculty,
      'department': department,
      'program': program,
      'level': level,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<LostFoundItem> lostFoundItem(String itemId) {
    return _db
        .collection('lost_found')
        .doc(itemId)
        .snapshots()
        .map((d) => LostFoundItem.fromMap(d.id, d.data() ?? {}));
  }

  Future<void> updateLostFoundStatus(String itemId, bool isResolved) async {
    await _db.collection('lost_found').doc(itemId).update({
      'isResolved': isResolved,
    });
  }

  Future<void> reportIncorrectListing(String itemId) async {
    await _db.collection('flags_lost_found').add({
      'itemId': itemId,
      'createdAt': FieldValue.serverTimestamp(),
    });
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

  Stream<List<LostFoundItem>> allLostFound() {
    return _db
        .collection('lost_found')
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

  Stream<List<PastQuestion>> pastQuestions({
    required String faculty,
    required String department,
    required String program,
    required String level,
    required String semester,
    required String course,
  }) {
    return _db
        .collection('past_questions')
        .where('faculty', isEqualTo: faculty)
        .where('department', isEqualTo: department)
        .where('program', isEqualTo: program)
        .where('level', isEqualTo: level)
        .where('semester', isEqualTo: semester)
        .where('course', isEqualTo: course)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PastQuestion.fromMap(d.id, d.data())).toList());
  }

  Stream<List<PastQuestion>> allPastQuestions() {
    return _db
        .collection('past_questions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PastQuestion.fromMap(d.id, d.data())).toList());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }
}

