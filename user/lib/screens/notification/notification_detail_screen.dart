import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/notification_provider.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final notifications = provider.notifications;
        final itemIndex = notifications.indexWhere((n) => n.id == notificationId);
        
        if (itemIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail')),
            body: const Center(child: Text('Notification not found.')),
          );
        }

        final item = notifications[itemIndex];

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Incident Details',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Full Image or Fallback Banner
                item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildBannerFallback(item, isDark),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 240,
                            color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                              ),
                            ),
                          );
                        },
                      )
                    : _buildBannerFallback(item, isDark),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta details header row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(AppColors.darkCardSubtle)
                                  : item.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isDark
                                    ? const Color(AppColors.darkBorder)
                                    : item.color.withOpacity(0.24),
                              ),
                            ),
                            child: Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                color: isDark ? const Color(AppColors.primaryLight) : item.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.timeAgo,
                            style: TextStyle(
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Main Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Location and Reporter Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(AppColors.darkCard) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Location Row
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsRegular.mapPin,
                                  size: 16,
                                  color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.location,
                                    style: TextStyle(
                                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            // Reporter Row
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsRegular.user,
                                  size: 16,
                                  color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Reported by ${item.reporter}',
                                    style: TextStyle(
                                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Incident description message
                      Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(
                        color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE5E7EB),
                      ),
                      const SizedBox(height: 16),

                      // React Section ("Is this report accurate?")
                      Text(
                        'Is this incident report accurate?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your feedback helps prevent false alarms and verify updates.',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Accurate Button
                          Expanded(
                            child: _reactionButton(
                              context: context,
                              isDark: isDark,
                              isSelected: item.userReaction == 'accurate',
                              label: 'Accurate',
                              count: item.accurateCount,
                              iconData: PhosphorIconsRegular.thumbsUp,
                              activeColor: isDark ? const Color(AppColors.primaryLight) : const Color(0xFF0F79B9),
                              onPressed: () => provider.react(item.id, 'accurate'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Inaccurate Button
                          Expanded(
                            child: _reactionButton(
                              context: context,
                              isDark: isDark,
                              isSelected: item.userReaction == 'inaccurate',
                              label: 'Inaccurate',
                              count: item.inaccurateCount,
                              iconData: PhosphorIconsRegular.thumbsDown,
                              activeColor: isDark ? const Color(AppColors.darkDanger) : const Color(0xFFE63946),
                              onPressed: () => provider.react(item.id, 'inaccurate'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerFallback(BUKNotification item, bool isDark) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(AppColors.darkCard) : null,
        gradient: isDark
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(0.08),
                  item.color.withOpacity(0.18),
                ],
              ),
      ),
      child: Center(
        child: Icon(
          item.icon,
          color: isDark ? const Color(AppColors.primaryLight) : item.color,
          size: 64,
        ),
      ),
    );
  }

  Widget _reactionButton({
    required BuildContext context,
    required bool isDark,
    required bool isSelected,
    required String label,
    required int count,
    required IconData iconData,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(isDark ? 0.16 : 0.08)
              : (isDark ? const Color(AppColors.darkCard) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 16,
              color: isSelected ? activeColor : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? activeColor : (isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withOpacity(0.18)
                    : (isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFEFF1F4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
