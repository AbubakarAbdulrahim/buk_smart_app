import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      await _messaging.getToken();
      FirebaseMessaging.onMessage.listen((_) {});
    } catch (_) {
      // Notifications are optional for app startup.
    }
  }
}
