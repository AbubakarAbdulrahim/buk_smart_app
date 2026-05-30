import 'package:flutter/material.dart';

import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/chatbot/chatbot_screen.dart';
import '../../screens/common/auth_gate.dart';
import '../../screens/common/splash_screen.dart';
import '../../screens/home/app_shell.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/resources/resources_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const authGate = '/auth-gate';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const chatbot = '/chatbot';
  static const pastQuestions = '/resources/past-questions';
  static const studentHandbook = '/resources/student-handbook';
  static const opportunities = '/resources/opportunities';
  static const eLibrary = '/resources/e-library';
  static const myReports = '/profile/my-reports';
  static const myLostFound = '/profile/my-lost-found';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) {
        switch (settings.name) {
          case splash:
            return const SplashScreen();
          case authGate:
            return const AuthGate();
          case onboarding:
            return const OnboardingScreen();
          case login:
            return const LoginScreen();
          case register:
            return const RegisterScreen();
          case forgotPassword:
            return ForgotPasswordScreen(initialEmail: settings.arguments as String?);
          case home:
            return const AppShell();
          case chatbot:
            return const ChatbotScreen();
          case pastQuestions:
            return const PastQuestionsScreen();
          case studentHandbook:
            return const StudentHandbookScreen();
          case opportunities:
            return const OpportunitiesScreen();
          case eLibrary:
            return const ELibraryScreen();
          case myReports:
            return MyReportsScreen(uid: settings.arguments! as String);
          case myLostFound:
            return MyLostFoundScreen(uid: settings.arguments! as String);
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
