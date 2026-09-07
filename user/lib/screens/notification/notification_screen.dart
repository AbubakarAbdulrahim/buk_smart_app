import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final notifications = provider.notifications;
        
        final filteredNotifications = _activeFilter == 'All'
            ? notifications
            : notifications.where((n) => n.category == _activeFilter).toList();

        final unreadCount = provider.unreadCount;

        return Scaffold(
          backgroundColor: isDark ? const Color(AppColors.darkBackground) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips Container
              Container(
                color: isDark ? const Color(AppColors.darkCard) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All', isDark),
                      const SizedBox(width: 8),
                      _filterChip('Security', isDark),
                      const SizedBox(width: 8),
                      _filterChip('Academic', isDark),
                      const SizedBox(width: 8),
                      _filterChip('Lost & Found', isDark),
                      const SizedBox(width: 8),
                      _filterChip('Updates', isDark),
                    ],
                  ),
                ),
              ),

              // Action Bar Below Filters
              if (unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () => provider.markAllAsRead(),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIconsRegular.checks,
                                size: 16,
                                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Mark all as read',
                                style: TextStyle(
                                  color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 6),

              // Notification List
              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: filteredNotifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = filteredNotifications[index];
                          return NotificationFeedCard(
                            item: item,
                            isDark: isDark,
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

  Widget _filterChip(String label, bool isDark) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper))
              : (isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(AppColors.darkTextPrimary) : const Color(0xFF475569)),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                PhosphorIconsRegular.bellSlash,
                size: 38,
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Caught Up',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No new $_activeFilter alerts or announcements at this time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationFeedCard extends StatelessWidget {
  const NotificationFeedCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  final BUKNotification item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Unread vs read card background (LinkedIn style)
    final cardBg = item.isRead
        ? (isDark ? const Color(AppColors.darkCard) : Colors.white)
        : (isDark ? const Color(0xFF1E2C3A) : const Color(0xFFEBF3FA));

    final borderColor = isDark
        ? (item.isRead ? const Color(AppColors.darkBorder) : const Color(0xFF2C435A))
        : (item.isRead ? const Color(0xFFEFF1F4) : const Color(0xFFCCE0F5));

    final hasPhoto = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: item.isRead ? 1 : 1.2),
        boxShadow: isDark
            ? []
            : [
                const BoxShadow(
                  color: Color(0x061B2430),
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
                // 1. TOP ROW: Subtle Consistent Category Pill + Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Subtle Consistent Category Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(AppColors.darkCardSubtle)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark
                              ? const Color(AppColors.darkBorder)
                              : const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          color: isDark
                              ? const Color(AppColors.darkTextSecondary)
                              : const Color(0xFF475569),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 2. MAIN ROW: Photo on the LEFT + Details on the RIGHT
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
                                item.imageUrl!,
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

                    // Title and Message on the RIGHT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 13,
                              color: isDark
                                  ? const Color(AppColors.darkTextPrimary)
                                  : const Color(AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(AppColors.darkTextSecondary)
                                  : const Color(AppColors.textSecondary),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                          if (item.location.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(AppColors.darkTextMuted)
                                    : const Color(0xFF94A3B8),
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
