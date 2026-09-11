import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/gemini_config.dart';
import 'core/providers/app_providers.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  await GeminiConfig.init();

  runApp(
    MultiProvider(
      providers: appProviders,
      child: const BukSmartApp(),
    ),
  );
}
