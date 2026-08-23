import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/notification_provider.dart';
import '../../widgets/app_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final notifications = provider.notifications;
        
        final filteredNotifications = _activeFilter == 'All'
            ? notifications
            : notifications.where((n) => n.category == _activeFilter).toList();

        final unreadCount = provider.unreadCount;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(AppColors.textPrimary),
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All'),
                      const SizedBox(width: 8),
                      _filterChip('Security'),
                      const SizedBox(width: 8),
                      _filterChip('Academic'),
                      const SizedBox(width: 8),
                      _filterChip('Lost & Found'),
                      const SizedBox(width: 8),
                      _filterChip('Updates'),
                    ],
                  ),
                ),
              ),

              // Mark all as read button below the filter categories
              if (unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: const Color(AppColors.primary).withOpacity(0.06),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => provider.markAllAsRead(),
                        label: const Text(
                          'Mark all as read',
                          style: TextStyle(
                            color: Color(AppColors.primaryDeeper),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Notification List
              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredNotifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filteredNotifications[index];
                          
                          // Facebook-style highlighting color
                          final cardBg = item.isRead ? Colors.white : const Color(0xFFEFF6FF);

                          return ContentCard(
                            item: item,
                            cardBg: cardBg,
                            onTap: () {
                              provider.markAsRead(item.id);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.notificationDetail,
                                arguments: item.id,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(AppColors.primaryDeeper) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(AppColors.textSecondary),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                PhosphorIconsRegular.bellSlash,
                size: 38,
                color: Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Caught Up',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No new $_activeFilter alerts or announcements at this time.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(AppColors.textSecondary),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.item,
    required this.cardBg,
    required this.onTap,
  });

  final BUKNotification item;
  final Color cardBg;
  final VoidCallback onTap;

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'verified':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = 'Verified';
        break;
      case 'resolved':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1D4ED8);
        label = 'Resolved';
        break;
      case 'unverified':
      default:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
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
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? const Color(0xFFEFF1F4) : const Color(0xFFBFDBFE),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081B2430),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),

              // Title and Description Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                  color: Color(AppColors.textSecondary),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.timeAgo,
                                style: const TextStyle(
                                  color: Color(AppColors.textSecondary),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                          fontSize: 14,
                          color: const Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
