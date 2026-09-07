import 'package:flutter/material.dart';

import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/common/auth_gate.dart';
import '../../screens/common/splash_screen.dart';
import '../../screens/home/app_shell.dart';
import '../../screens/notification/notification_screen.dart';
import '../../screens/notification/notification_detail_screen.dart';
import '../../screens/emergency/emergency_contacts_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/updates/campus_updates_screen.dart';
import '../../screens/updates/campus_update_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/change_password_screen.dart';
import '../../screens/profile/terms_of_service_screen.dart';
import '../../screens/profile/privacy_policy_screen.dart';
import '../../screens/resources/resources_screen.dart';
import '../../screens/report/cloudinary_upload_demo_screen.dart';
import '../../screens/lost_found/lost_found_detail_screen.dart';
import '../../screens/lost_found/lost_found_wizard_screen.dart';
import '../../screens/lost_found/lost_found_bookmarks_screen.dart';
import '../../screens/home/smart_ai_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const authGate = '/auth-gate';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const pastQuestions = '/resources/past-questions';
  static const fypSiwes = '/resources/fyp-siwes';
  static const studentHandbook = '/resources/student-handbook';
  static const opportunities = '/resources/opportunities';
  static const eLibrary = '/resources/e-library';
  static const myReports = '/profile/my-reports';
  static const myLostFound = '/profile/my-lost-found';
  static const editProfile = '/profile/edit';
  static const notifications = '/notifications';
  static const notificationDetail = '/notifications/detail';
  static const emergencyContacts = '/emergency-contacts';
  static const analytics = '/analytics';
  static const campusUpdates = '/updates';
  static const campusUpdateDetail = '/updates/detail';
  static const cloudinaryUploadDemo = '/cloudinary-upload-demo';
  static const lostFoundDetail = '/lost-found/detail';
  static const lostFoundWizard = '/lost-found/report';
  static const lostFoundBookmarks = '/lost-found/bookmarks';
  static const smartAi = '/smart-ai';
  static const profileSettings = '/profile/settings';
  static const changePassword = '/profile/change-password';
  static const termsOfService = '/terms-of-service';
  static const privacyPolicy = '/privacy-policy';

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
          case pastQuestions:
            return const PastQuestionsScreen();
          case fypSiwes:
            return const FypSiwesScreen();
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
          case editProfile:
            return const EditProfileScreen();
          case notifications:
            return const NotificationScreen();
          case notificationDetail:
            return NotificationDetailScreen(notificationId: settings.arguments! as String);
          case emergencyContacts:
            return const EmergencyContactsScreen();
          case analytics:
            return const AnalyticsScreen();
          case campusUpdates:
            return const CampusUpdatesScreen();
          case campusUpdateDetail:
            return CampusUpdateDetailScreen(updateId: settings.arguments! as String);
          case cloudinaryUploadDemo:
            return const CloudinaryUploadDemoScreen();
          case lostFoundDetail:
            return LostFoundDetailScreen(itemId: settings.arguments! as String);
          case lostFoundWizard:
            return const LostFoundWizardScreen();
          case lostFoundBookmarks:
            return const LostFoundBookmarksScreen();
          case smartAi:
            return const SmartAiPage();
          case profileSettings:
            return const SettingsScreen();
          case changePassword:
            return const ChangePasswordScreen();
          case termsOfService:
            return const TermsOfServiceScreen();
          case privacyPolicy:
            return const PrivacyPolicyScreen();
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
