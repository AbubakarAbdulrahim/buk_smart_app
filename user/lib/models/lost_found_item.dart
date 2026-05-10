import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundItem {
  const LostFoundItem({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.contact,
    required this.type,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String userId;
  final String category;
  final String title;
  final String description;
  final String location;
  final String contact;
  final String type;
  final DateTime createdAt;
  final String? imageUrl;

  factory LostFoundItem.fromMap(String id, Map<String, dynamic> data) => LostFoundItem(
        id: id,
        userId: data['userId'] ?? '',
        category: data['category'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        contact: data['contact'] ?? '',
        type: data['type'] ?? 'lost',
        imageUrl: data['imageUrl'],
        createdAt: _parseDate(data['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'category': category,
        'title': title,
        'description': description,
        'location': location,
        'contact': contact,
        'type': type,
        'imageUrl': imageUrl,
      };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
