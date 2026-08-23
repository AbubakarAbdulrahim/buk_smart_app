import 'package:cloud_firestore/cloud_firestore.dart';

class PastQuestion {
  const PastQuestion({
    required this.id,
    required this.title,
    required this.faculty,
    required this.department,
    required this.program,
    required this.level,
    required this.semester,
    required this.course,
    required this.fileUrl,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String faculty;
  final String department;
  final String program;
  final String level;
  final String semester;
  final String course;
  final String fileUrl;
  final String fileSize;
  final DateTime createdAt;

  factory PastQuestion.fromMap(String id, Map<String, dynamic> data) {
    return PastQuestion(
      id: id,
      title: data['title'] ?? '',
      faculty: data['faculty'] ?? '',
      department: data['department'] ?? '',
      program: data['program'] ?? '',
      level: data['level'] ?? '',
      semester: data['semester'] ?? '',
      course: data['course'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileSize: data['fileSize'] ?? 'PDF',
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
