import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';
import '../../models/incident.dart';

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
  NotificationProvider() {
    _initIncidentsStream();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incidentsSub;
  final Set<String> _readIds = {};
  final Map<String, String> _userReactions = {};

  List<BUKNotification> _notifications = [];

  List<BUKNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static final Map<String, Color> _categoryColors = {
    'Insecurity': const Color(0xFFEF4444),
    'Theft': const Color(0xFFF59E0B),
    'Emergency': const Color(0xFFEC4899),
    'Power Outage': const Color(0xFF6366F1),
    'Water Outage': const Color(0xFF06B6D4),
    'Fire Outbreak': const Color(0xFFF97316),
    'Waste Dumps': const Color(0xFF84CC16),
    'Security': const Color(0xFFEF4444),
    'Other': const Color(0xFF8B5CF6),
  };

  static final Map<String, IconData> _categoryIcons = {
    'Insecurity': PhosphorIconsRegular.shieldWarning,
    'Theft': PhosphorIconsRegular.lockSimple,
    'Emergency': PhosphorIconsRegular.firstAid,
    'Power Outage': PhosphorIconsRegular.lightning,
    'Water Outage': PhosphorIconsRegular.drop,
    'Fire Outbreak': PhosphorIconsRegular.fire,
    'Waste Dumps': PhosphorIconsRegular.trash,
    'Security': PhosphorIconsRegular.shieldWarning,
    'Other': PhosphorIconsRegular.warningCircle,
  };

  void _initIncidentsStream() {
    try {
      _incidentsSub = FirebaseFirestore.instance
          .collection('incidents')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final List<BUKNotification> list = [];
          for (final doc in snapshot.docs) {
            final incident = Incident.fromMap(doc.id, doc.data());
            list.add(_incidentToNotification(incident));
          }
          _notifications = list;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Firestore incidents stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to subscribe to Firestore incidents: $e');
    }
  }

  BUKNotification _incidentToNotification(Incident inc) {
    final cat = inc.type.trim().isEmpty ? 'Security' : inc.type.trim();
    final catColor = _categoryColors[cat] ?? const Color(AppColors.primaryDeeper);
    final catIcon = _categoryIcons[cat] ?? PhosphorIconsRegular.shieldWarning;

    return BUKNotification(
      id: inc.id,
      title: '$cat Incident',
      message: inc.description.isNotEmpty ? inc.description : 'Incident reported at ${inc.location}',
      timeAgo: _formatTimeAgo(inc.createdAt),
      category: cat,
      icon: catIcon,
      color: catColor,
      reporter: (inc.reporterName != null && inc.reporterName!.isNotEmpty)
          ? inc.reporterName!
          : 'BUK Student',
      location: inc.location,
      accurateCount: inc.accurateCount,
      inaccurateCount: inc.inaccurateCount,
      status: inc.isResolved
          ? 'resolved'
          : (inc.isVerified ? 'verified' : (inc.status.isNotEmpty ? inc.status : 'unverified')),
      imageUrl: inc.imageUrl,
      isRead: _readIds.contains(inc.id),
      userReaction: _userReactions[inc.id],
    );
  }

  BUKNotification incidentToNotification(Incident inc) => _incidentToNotification(inc);

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  /// Optimistically adds a newly reported incident immediately to the top of the feed
  void addIncidentLocally(Incident incident) {
    final notif = _incidentToNotification(incident);
    _notifications.removeWhere((n) => n.id == incident.id);
    _notifications.insert(0, notif);
    notifyListeners();
  }

  void markAsRead(String id) {
    _readIds.add(id);
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
      _readIds.add(n.id);
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
      notif.userReaction = null;
      _userReactions.remove(id);
      if (reaction == 'accurate') {
        notif.accurateCount = (notif.accurateCount - 1).clamp(0, 9999);
      } else {
        notif.inaccurateCount = (notif.inaccurateCount - 1).clamp(0, 9999);
      }
    } else {
      if (notif.userReaction == 'accurate') {
        notif.accurateCount = (notif.accurateCount - 1).clamp(0, 9999);
      } else if (notif.userReaction == 'inaccurate') {
        notif.inaccurateCount = (notif.inaccurateCount - 1).clamp(0, 9999);
      }

      notif.userReaction = reaction;
      _userReactions[id] = reaction;
      if (reaction == 'accurate') {
        notif.accurateCount++;
      } else {
        notif.inaccurateCount++;
      }

      // Persist reaction count to Firestore if the document exists
      try {
        FirebaseFirestore.instance.collection('incidents').doc(id).update({
          if (reaction == 'accurate') 'accurateCount': FieldValue.increment(1),
          if (reaction == 'inaccurate') 'inaccurateCount': FieldValue.increment(1),
        }).catchError((e) {
          debugPrint('Could not persist reaction to Firestore: $e');
        });
      } catch (e) {
        debugPrint('Firestore reaction update error: $e');
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _incidentsSub?.cancel();
    super.dispose();
  }
}
