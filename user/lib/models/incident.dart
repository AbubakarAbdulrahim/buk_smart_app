import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  const Incident({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.location,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String userId;
  final String type;
  final String description;
  final String location;
  final DateTime createdAt;
  final String? imageUrl;

  factory Incident.fromMap(String id, Map<String, dynamic> data) => Incident(
        id: id,
        userId: data['userId'] ?? '',
        type: data['type'] ?? '',
        description: data['description'] ?? '',
        location: data['location'] ?? '',
        imageUrl: data['imageUrl'],
        createdAt: _parseDate(data['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'description': description,
        'location': location,
        'imageUrl': imageUrl,
      };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
