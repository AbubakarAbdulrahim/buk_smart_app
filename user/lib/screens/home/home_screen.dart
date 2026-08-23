import 'dart:async';
import 'package:flutter/material.dart';
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
import '../lost_found/lost_found_screen.dart';
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

  void _showComingSoon(BuildContext context, String serviceName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(PhosphorIconsRegular.sparkle, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$serviceName portal will be available in the next app update!',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final user = auth.currentUser;

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: user == null ? const Stream.empty() : firestore.userProfile(user.uid),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() ?? {};
                final fullName = data['name'] as String? ?? 'Abubakar';
                final firstName = fullName.trim().split(' ').first;
                final photoUrl = data['photoUrl'] as String?;

                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(AppColors.border),
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
                                  return const Icon(
                                    PhosphorIconsRegular.user,
                                    color: Color(AppColors.textSecondary),
                                  );
                                },
                              )
                            : const Icon(
                                PhosphorIconsRegular.user,
                                color: Color(AppColors.textSecondary),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, $firstName', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                          const Text('Good Morning!', style: TextStyle(color: Color(AppColors.textSecondary))),
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
                              icon: const Icon(PhosphorIconsRegular.bell, color: Color(AppColors.textSecondary)),
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
            // const AppSectionHeader(title: 'Campus Updates'),
            // const SizedBox(height: 10),
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(AppColors.border)),
                                  boxShadow: const [
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
                                              color: const Color(AppColors.primaryDeeper).withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              update.tag,
                                              style: const TextStyle(color: Color(AppColors.primaryDeeper), fontWeight: FontWeight.w600, fontSize: 10.5),
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
                                              style: const TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.bold, fontSize: 14.5),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              update.subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 11.5, height: 1.25),
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
                            color: _currentPage == index ? const Color(AppColors.primaryDeeper) : const Color(AppColors.border),
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
              title: 'Recent Activity',
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
    return SectionCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Image Thumbnail (with fallback)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: report.imageUrl != null && report.imageUrl!.isNotEmpty
                        ? Image.network(
                            report.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(AppColors.primaryDeeper),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                const SizedBox(width: 14),
                // Right Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and Datetime
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              report.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: Color(AppColors.textPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                report.timeAgo,
                                style: const TextStyle(
                                  color: Color(AppColors.textSecondary),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildStatusBadge(report.status),
                            ],
                          ),
                        ],
                      ),
                      // const SizedBox(height: 4),
                      // Location Row
                      Row(
                        children: [
                          const Icon(
                            PhosphorIconsRegular.mapPin,
                            size: 13,
                            color: Color(AppColors.textSecondary),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(AppColors.textSecondary),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Reporter Row
                    Row(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.user,
                          size: 13,
                          color: Color(AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Reported by ${report.reporter}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(AppColors.textSecondary),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'verified':
        bgColor = const Color(AppColors.success).withOpacity(0.12);
        textColor = const Color(AppColors.success);
        label = 'Verified';
        break;
      case 'resolved':
        bgColor = const Color(AppColors.info).withOpacity(0.12);
        textColor = const Color(AppColors.info);
        label = 'Resolved';
        break;
      case 'unverified':
      default:
        bgColor = const Color(AppColors.danger).withOpacity(0.12);
        textColor = const Color(AppColors.danger);
        label = 'Unverified';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F79B9).withOpacity(0.08),
            const Color(0xFF0F79B9).withOpacity(0.18),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          PhosphorIconsRegular.image,
          color: Color(AppColors.primaryDeeper),
          size: 20,
        ),
      ),
    );
  }
}
