import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/gemini_service.dart';
import '../../services/smart_ai_repository.dart';
import 'notification_provider.dart';
import 'campus_updates_provider.dart';

final appProviders = [
  Provider<AuthService>(create: (_) => AuthService()),
  Provider<FirestoreService>(create: (_) => FirestoreService()),
  Provider<GeminiService>(create: (_) => GeminiService(), dispose: (_, svc) => svc.dispose()),
  Provider<SmartAiRepository>(create: (_) => SmartAiRepository()),
  ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
  ChangeNotifierProvider<CampusUpdatesProvider>(create: (_) => CampusUpdatesProvider()),
];
