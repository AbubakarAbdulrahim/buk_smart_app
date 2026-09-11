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
    this.status = 'pending',
    this.isVerified = false,
    this.isResolved = false,
    this.reporterName,
    this.accurateCount = 0,
    this.inaccurateCount = 0,
  });

  final String id;
  final String userId;
  final String type;
  final String description;
  final String location;
  final DateTime createdAt;
  final String? imageUrl;
  final String status;
  final bool isVerified;
  final bool isResolved;
  final String? reporterName;
  final int accurateCount;
  final int inaccurateCount;

  Incident copyWith({
    String? id,
    String? userId,
    String? type,
    String? description,
    String? location,
    DateTime? createdAt,
    String? imageUrl,
    String? status,
    bool? isVerified,
    bool? isResolved,
    String? reporterName,
    int? accurateCount,
    int? inaccurateCount,
  }) {
    return Incident(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isResolved: isResolved ?? this.isResolved,
      reporterName: reporterName ?? this.reporterName,
      accurateCount: accurateCount ?? this.accurateCount,
      inaccurateCount: inaccurateCount ?? this.inaccurateCount,
    );
  }

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    final statusVal = (data['status'] as String?) ?? 'pending';
    final isVerifiedVal = data['isVerified'] as bool? ?? (statusVal.toLowerCase() == 'verified');
    final isResolvedVal = data['isResolved'] as bool? ?? (statusVal.toLowerCase() == 'resolved');

    return Incident(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      status: statusVal,
      isVerified: isVerifiedVal,
      isResolved: isResolvedVal,
      reporterName: (data['reporterName'] as String?) ?? (data['userName'] as String?),
      accurateCount: (data['accurateCount'] as num?)?.toInt() ?? 0,
      inaccurateCount: (data['inaccurateCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'description': description,
        'location': location,
        'imageUrl': imageUrl,
        'status': status,
        'isVerified': isVerified,
        'isResolved': isResolved,
        if (reporterName != null) 'reporterName': reporterName,
        'accurateCount': accurateCount,
        'inaccurateCount': inaccurateCount,
      };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
