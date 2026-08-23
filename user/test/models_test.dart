import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartbuk/models/incident.dart';
import 'package:smartbuk/models/lost_found_item.dart';

void main() {
  test('Incident parses firestore timestamp', () {
    final incident = Incident.fromMap('1', {
      'userId': 'u1',
      'type': 'Theft',
      'description': 'desc',
      'location': 'loc',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });

    expect(incident.userId, 'u1');
    expect(incident.createdAt.year, 2026);
  });

  test('LostFound parses firestore timestamp', () {
    final item = LostFoundItem.fromMap('1', {
      'userId': 'u1',
      'category': 'ID',
      'title': 'Card',
      'description': 'desc',
      'location': 'loc',
      'contact': 'mail',
      'type': 'lost',
      'createdAt': Timestamp.fromDate(DateTime(2026, 2, 2)),
    });

    expect(item.title, 'Card');
    expect(item.createdAt.month, 2);
  });
}
