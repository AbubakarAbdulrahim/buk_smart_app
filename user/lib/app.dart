import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/common/splash_screen.dart';

class BukSmartApp extends StatelessWidget {
  const BukSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
