import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BUKNotification {
  BUKNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    required this.icon,
    required this.color,
    required this.reporter,
    required this.location,
    required this.accurateCount,
    required this.inaccurateCount,
    required this.status,
    this.imageUrl,
    this.isRead = false,
    this.userReaction,
  });

  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category;
  final IconData icon;
  final Color color;
  final String reporter;
  final String location;
  int accurateCount;
  int inaccurateCount;
  final String? imageUrl;
  bool isRead;
  String? userReaction; // 'accurate', 'inaccurate', or null
  final String status; // 'unverified', 'verified', 'resolved'
}

class NotificationProvider extends ChangeNotifier {
  final List<BUKNotification> _notifications = [
    BUKNotification(
      id: 'n1',
      title: 'Security Alert: Theft Incident',
      message: 'A minor theft of study materials was reported at the Old Site library hall. Students are advised to monitor personal items.',
      timeAgo: '5m ago',
      category: 'Security',
      icon: PhosphorIconsRegular.shieldWarning,
      color: const Color(0xFFE63946),
      reporter: 'Abubakar Ali',
      location: 'Old Site Library Hall',
      accurateCount: 14,
      inaccurateCount: 2,
      status: 'unverified',
      imageUrl: null,
      isRead: false,
    ),
    BUKNotification(
      id: 'n2',
      title: 'Lost Found item matching',
      message: 'A student identity card belonging to Ibrahim Bello was found at the Faculty of Science and turned in.',
      timeAgo: '1h ago',
      category: 'Lost & Found',
      icon: PhosphorIconsRegular.magnifyingGlass,
      color: const Color(0xFFF59E0B),
      reporter: 'Fatima Umar',
      location: 'Faculty of Science Room C',
      accurateCount: 8,
      inaccurateCount: 0,
      status: 'verified',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&auto=format&fit=crop&q=60',
      isRead: false,
    ),
    BUKNotification(
      id: 'n3',
      title: 'AI Ethics Seminar Scheduled',
      message: 'The Faculty of Computer Science invites all undergraduate students to attend the upcoming AI ethics seminar at CITS Hall tomorrow.',
      timeAgo: '4h ago',
      category: 'Academic',
      icon: PhosphorIconsRegular.bookOpen,
      color: const Color(0xFF3B82F6),
      reporter: 'Dr. Kabir Bashir',
      location: 'CITS Hall, New Site',
      accurateCount: 32,
      inaccurateCount: 1,
      status: 'resolved',
      imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500&auto=format&fit=crop&q=60',
      isRead: true,
    ),
    BUKNotification(
      id: 'n4',
      title: 'Emergency Drill Schedule',
      message: 'Routine emergency response and evacuation preparedness drill is scheduled for Friday morning at the Administrative Complex.',
      timeAgo: 'Yesterday',
      category: 'Updates',
      icon: PhosphorIconsRegular.megaphone,
      color: const Color(0xFF10B981),
      reporter: 'Chief Security Officer',
      location: 'Administrative Complex',
      accurateCount: 25,
      inaccurateCount: 3,
      status: 'unverified',
      imageUrl: null,
      isRead: true,
    ),
  ];

  List<BUKNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && idx < _notifications.length) {
      if (!_notifications[idx].isRead) {
        _notifications[idx].isRead = true;
        notifyListeners();
      }
    }
  }

  void markAllAsRead() {
    bool updated = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        updated = true;
      }
    }
    if (updated) {
      notifyListeners();
    }
  }

  void react(String id, String reaction) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    final notif = _notifications[idx];
    if (notif.userReaction == reaction) {
      // Toggle off the active reaction
      notif.userReaction = null;
      if (reaction == 'accurate') {
        notif.accurateCount--;
      } else {
        notif.inaccurateCount--;
      }
    } else {
      // Toggle on/change the active reaction
      if (notif.userReaction == 'accurate') {
        notif.accurateCount--;
      } else if (notif.userReaction == 'inaccurate') {
        notif.inaccurateCount--;
      }

      notif.userReaction = reaction;
      if (reaction == 'accurate') {
        notif.accurateCount++;
      } else {
        notif.inaccurateCount++;
      }
    }

    notifyListeners();
  }
}
