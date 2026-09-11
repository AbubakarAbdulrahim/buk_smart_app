import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory ChatSession.fromMap(String id, Map<String, dynamic> data) {
    return ChatSession(
      id: id,
      title: data['title'] as String? ?? 'New Chat',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class ChatMessage {
  final String id;
  final String role; // 'user' or 'model'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      role: data['role'] as String? ?? 'user',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SmartAiRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retrieves all chat sessions for a specific user ordered by updatedAt descending.
  Stream<List<ChatSession>> getSessions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatSession.fromMap(doc.id, doc.data())).toList();
    });
  }

  /// Retrieves all chat messages for a specific session ordered by createdAt ascending.
  Stream<List<ChatMessage>> getMessages(String uid, String sessionId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.id, doc.data())).toList();
    });
  }

  /// Generates a unique session document ID synchronously on the client.
  String generateSessionId(String uid) {
    return _db.collection('users').doc(uid).collection('chats').doc().id;
  }

  /// Persists a new chat session metadata using an existing session ID.
  Future<void> saveSession(String uid, String sessionId, String firstMsg) async {
    final title = firstMsg.length > 30 ? '${firstMsg.substring(0, 27).trim()}...' : firstMsg;
    await _db.collection('users').doc(uid).collection('chats').doc(sessionId).set({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Creates a new chat session using a snippet of the first user message as the title.
  Future<String> createSession(String uid, String firstMsg) async {
    final sessionId = generateSessionId(uid);
    await saveSession(uid, sessionId, firstMsg);
    return sessionId;
  }

  /// Adds a message in a session subcollection and updates session timestamp.
  Future<void> addMessage(String uid, String sessionId, String role, String content) async {
    final chatDoc = _db.collection('users').doc(uid).collection('chats').doc(sessionId);
    
    // Add message
    await chatDoc.collection('messages').add({
      'role': role,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update session timestamp
    await chatDoc.update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates the title of a specific chat session.
  Future<void> updateSessionTitle(String uid, String sessionId, String newTitle) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(sessionId)
        .update({'title': newTitle});
  }

  /// Deletes a chat session along with all its subcollection messages.
  Future<void> deleteSession(String uid, String sessionId) async {
    final chatDoc = _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(sessionId);

    // Delete subcollection messages
    final messagesSnapshot = await chatDoc.collection('messages').get();
    final batch = _db.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete session document
    batch.delete(chatDoc);
    await batch.commit();
  }
}
