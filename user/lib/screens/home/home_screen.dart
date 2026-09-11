import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/routes/app_routes.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/providers/campus_updates_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/smart_ai_fab.dart';
import '../report/report_incident_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.94);
  int _currentPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final provider = Provider.of<CampusUpdatesProvider>(context, listen: false);
      if (provider.updates.isEmpty) return;
      final next = (_currentPage + 1) % provider.updates.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  String _deriveFirstName(Map<String, dynamic> data, User? user) {
    // 1. Direct field in Firestore document
    String? name = data['name'] as String? ?? data['fullName'] as String? ?? data['firstName'] as String?;

    // 2. Firebase Auth display name if Firestore is still loading or empty
    if (name == null || name.trim().isEmpty || name.trim().toLowerCase() == 'user') {
      name = user?.displayName;
    }

    // 3. Extract readable name from student email (e.g. "abubakar.ali" -> "Abubakar")
    if (name == null || name.trim().isEmpty || name.trim().toLowerCase() == 'user') {
      if (user?.email != null && user!.email!.contains('@')) {
        final prefix = user.email!.split('@').first;
        final parts = prefix.split(RegExp(r'[._\-]'));
        if (parts.isNotEmpty && parts.first.isNotEmpty) {
          final raw = parts.first;
          name = raw[0].toUpperCase() + (raw.length > 1 ? raw.substring(1) : '');
        }
      }
    }

    if (name == null || name.trim().isEmpty) {
      name = 'Student';
    }

    final first = name.trim().split(' ').first;
    return first.isNotEmpty ? (first[0].toUpperCase() + (first.length > 1 ? first.substring(1) : '')) : 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      (
        title: 'Report Incident',
        description: 'Report security or safety concerns',
        icon: PhosphorIconsRegular.shieldWarning,
        color: const Color(AppColors.blueSky),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
          );
        },
      ),
      (
        title: 'View Analytics',
        description: 'Check campus crime & safety trends',
        icon: PhosphorIconsRegular.chartBar,
        color: const Color(AppColors.blueSky),
        onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
      ),
      (
        title: 'Campus Updates',
        description: 'News, events & announcements',
        icon: PhosphorIconsRegular.newspaper,
        color: const Color(AppColors.blueSky),
        onTap: () => Navigator.pushNamed(context, AppRoutes.campusUpdates),
      ),
      (
        title: 'Emergency Contacts',
        description: 'Quick access to emergency numbers',
        icon: PhosphorIconsRegular.phoneCall,
        color: const Color(AppColors.blueSky),
        onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyContacts),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: user == null ? const Stream.empty() : firestore.userProfile(user.uid),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() ?? {};
                  final firstName = _deriveFirstName(data, user);
                  final photoUrl = (data['photoUrl'] as String?) ?? user?.photoURL;
                  final timeGreeting = _getTimeGreeting();

                  return Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      PhosphorIconsRegular.user,
                                      color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                    );
                                  },
                                )
                              : Icon(
                                  PhosphorIconsRegular.user,
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hi, $firstName', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                            Text(
                              timeGreeting,
                              style: TextStyle(
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<NotificationProvider>(
                        builder: (context, notificationProvider, child) {
                          final unreadCount = notificationProvider.unreadCount;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                                icon: Icon(
                                  PhosphorIconsRegular.bell,
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: Color(AppColors.danger),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 15),
              Consumer<CampusUpdatesProvider>(
                builder: (context, updatesProvider, child) {
                  final updatesList = updatesProvider.updates;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 98,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: updatesList.length,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemBuilder: (context, index) {
                            final update = updatesList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.campusUpdateDetail,
                                  arguments: update.id,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(AppColors.darkBorder)
                                          : const Color(AppColors.border),
                                    ),
                                    boxShadow: isDark
                                        ? []
                                        : const [
                                            BoxShadow(color: Color(0x060A1320), blurRadius: 16, offset: Offset(0, 8)),
                                          ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(AppColors.primaryDeeper).withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                update.tag,
                                                style: const TextStyle(
                                                  color: Color(AppColors.primaryDeeper),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                update.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                update.subtitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                                  fontSize: 11.5,
                                                  height: 1.25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          updatesList.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(AppColors.primaryDeeper)
                                  : (isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border)),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const AppSectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 10),
              GridView.builder(
                itemCount: actions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (_, i) {
                  final item = actions[i];
                  return QuickActionCard(
                    title: item.title,
                    description: item.description,
                    icon: item.icon,
                    accentColor: item.color,
                    onTap: item.onTap,
                  );
                },
              ),
              const SizedBox(height: 20),
              AppSectionHeader(
                title: 'Recent Incidents',
                trailing: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Color(AppColors.primaryDeeper),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final recentReports = notificationProvider.notifications.take(3).toList();

                  if (recentReports.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(AppColors.darkCard) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIconsRegular.shieldCheck,
                              size: 32,
                              color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No recent incidents reported.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Campus is peaceful. Tap "Report Incident" above to report a concern.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentReports.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final report = recentReports[index];
                      return RecentActivityCard(
                        report: report,
                        onTap: () {
                          notificationProvider.markAsRead(report.id);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.notificationDetail,
                            arguments: report.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const SmartAiFab(),
    );
  }
}

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  final BUKNotification report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = report.imageUrl != null && report.imageUrl!.isNotEmpty;

    final cardBg = isDark ? const Color(AppColors.darkCard) : Colors.white;
    final borderColor = isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Color(0x050B1A2B),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header: Category Tag + TimeAgo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        report.category.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF475569),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Text(
                      report.timeAgo,
                      style: TextStyle(
                        color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 2. Main Row: Photo on the LEFT + Details on the RIGHT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Thumbnail on the LEFT
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: hasPhoto
                            ? Image.network(
                                report.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Image.asset(
                                    'assets/images/buk_logo.png',
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDark
                                            ? const Color(AppColors.primaryLight)
                                            : const Color(AppColors.primaryDeeper),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Image.asset(
                                  'assets/images/buk_logo.png',
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Details on the RIGHT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                          if (report.location.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              report.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
