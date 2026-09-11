import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CampusUpdate {
  CampusUpdate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.tag,
    required this.icon,
    required this.gradient,
    required this.date,
    required this.reactions,
    this.userReaction,
  });

  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String tag;
  final IconData icon;
  final List<Color> gradient;
  final String date;
  final Map<String, int> reactions;
  String? userReaction;
}

// TODO(real-data): No Firestore 'campus_updates' collection exists in the current backend schema.
// When the 'campus_updates' Firestore collection is provisioned with server-side authoring,
// wire CampusUpdatesProvider to listen to Firestore snapshots and persist reactions.
class CampusUpdatesProvider extends ChangeNotifier {
  final List<CampusUpdate> _updates = [
    CampusUpdate(
      id: 'u1',
      title: 'Faculty Seminar on AI Ethics',
      subtitle: 'Monday, 10:00 AM at CITS Hall. Open to all departments.',
      content: 'The Faculty of Computer Science invites all students, faculty members, and researchers to attend this critical guest seminar. Dr. Kabir Bashir will lead the presentation discussing ethical considerations of generative AI models in student projects and university research standards. Light refreshments will be served at the CITS Hall.',
      tag: 'Seminar',
      icon: PhosphorIconsRegular.megaphone,
      gradient: [const Color(0xFF0085D0), const Color(0xFF39A9E6)],
      date: 'July 2, 2026',
      reactions: {'👍': 5, '❤️': 8, '😂': 0, '😢': 0, '😮': 1},
    ),
    CampusUpdate(
      id: 'u2',
      title: 'Guest Lecture: Cybersecurity in Practice',
      subtitle: 'Join the industry session at Old Site Lecture Theatre by 2:00 PM.',
      content: 'We are hosting a leading cybersecurity audit officer from industry to talk about security operations center (SOC) frameworks, real-world data breaches in finance, and career tracks in digital forensics. All information technology students are encouraged to attend this practical lab session.',
      tag: 'Lecture',
      icon: PhosphorIconsRegular.graduationCap,
      gradient: [const Color(0xFF0E5E96), const Color(0xFF0085D0)],
      date: 'July 1, 2026',
      reactions: {'👍': 12, '❤️': 3, '😂': 0, '😢': 0, '😮': 2},
    ),
    CampusUpdate(
      id: 'u3',
      title: 'Students Week Registration Now Open',
      subtitle: 'Register before Friday for debates, sports, exhibitions, and awards.',
      content: 'BUK Students Union announces the commencement of registration for the annual Student Association games, tech hackathons, debate cups, cultural dances, and awards nights. Students must form departmental groups and submit team rosters online before this Friday.',
      tag: 'Campus Update',
      icon: PhosphorIconsRegular.sparkle,
      gradient: [const Color(0xFF004E7A), const Color(0xFF0F79B9)],
      date: 'June 30, 2026',
      reactions: {'👍': 24, '❤️': 15, '😂': 2, '😢': 0, '😮': 4},
    ),
  ];

  List<CampusUpdate> get updates => _updates;

  void toggleReaction(String updateId, String emoji) {
    final idx = _updates.indexWhere((u) => u.id == updateId);
    if (idx == -1) return;

    final update = _updates[idx];
    if (update.userReaction == emoji) {
      // Toggle off
      update.userReaction = null;
      update.reactions[emoji] = (update.reactions[emoji] ?? 1) - 1;
    } else {
      // Toggle off previous reaction if any
      if (update.userReaction != null) {
        final prevEmoji = update.userReaction!;
        update.reactions[prevEmoji] = (update.reactions[prevEmoji] ?? 1) - 1;
      }
      // Set new reaction
      update.userReaction = emoji;
      update.reactions[emoji] = (update.reactions[emoji] ?? 0) + 1;
    }

    notifyListeners();
  }
}
