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
    this.color,
    this.brand,
    this.uniqueFeatures,
    this.contactType,
    this.isResolved = false,
    this.isVerified = false,
    this.bookmarkedBy = const [], // Keep track of users who bookmarked this item
    this.imageUrls = const [], // Support multiple image carousel
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
  final String? color;
  final String? brand;
  final String? uniqueFeatures;
  final String? contactType;
  final bool isResolved;
  final bool isVerified;
  final List<String> bookmarkedBy;
  final List<String> imageUrls;

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
        color: data['color'],
        brand: data['brand'],
        uniqueFeatures: data['uniqueFeatures'],
        contactType: data['contactType'],
        isResolved: data['isResolved'] ?? false,
        isVerified: data['isVerified'] ?? false,
        bookmarkedBy: List<String>.from(data['bookmarkedBy'] ?? []),
        imageUrls: List<String>.from(data['imageUrls'] ?? []),
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
        'color': color,
        'brand': brand,
        'uniqueFeatures': uniqueFeatures,
        'contactType': contactType,
        'isResolved': isResolved,
        'isVerified': isVerified,
        'bookmarkedBy': bookmarkedBy,
        'imageUrls': imageUrls,
      };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
