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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Incident Details',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(AppColors.textPrimary),
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
                        errorBuilder: (context, error, stackTrace) => _buildBannerFallback(item),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 240,
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(AppColors.primaryDeeper),
                              ),
                            ),
                          );
                        },
                      )
                    : _buildBannerFallback(item),

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
                              color: item.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                color: item.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.timeAgo,
                            style: const TextStyle(
                              color: Color(AppColors.textSecondary),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Color(AppColors.textPrimary),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Location and Reporter Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            // Location Row
                            Row(
                              children: [
                                const Icon(
                                  PhosphorIconsRegular.mapPin,
                                  size: 16,
                                  color: Color(AppColors.primaryDeeper),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.location,
                                    style: const TextStyle(
                                      color: Color(AppColors.textPrimary),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: Color(0xFFE2E8F0)),
                            ),
                            // Reporter Row
                            Row(
                              children: [
                                const Icon(
                                  PhosphorIconsRegular.user,
                                  size: 16,
                                  color: Color(AppColors.primaryDeeper),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Reported by ${item.reporter}',
                                    style: const TextStyle(
                                      color: Color(AppColors.textPrimary),
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
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.message,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: Color(AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // React Section ("Is this report accurate?")
                      const Text(
                        'Is this incident report accurate?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your feedback helps prevent false alarms and verify updates.',
                        style: TextStyle(
                          color: Color(AppColors.textSecondary),
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
                              isSelected: item.userReaction == 'accurate',
                              label: 'Accurate',
                              count: item.accurateCount,
                              iconData: PhosphorIconsRegular.thumbsUp,
                              activeColor: const Color(0xFF0F79B9),
                              onPressed: () => provider.react(item.id, 'accurate'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Inaccurate Button
                          Expanded(
                            child: _reactionButton(
                              context: context,
                              isSelected: item.userReaction == 'inaccurate',
                              label: 'Inaccurate',
                              count: item.inaccurateCount,
                              iconData: PhosphorIconsRegular.thumbsDown,
                              activeColor: const Color(0xFFE63946),
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

  Widget _buildBannerFallback(BUKNotification item) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
          color: item.color,
          size: 64,
        ),
      ),
    );
  }

  Widget _reactionButton({
    required BuildContext context,
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
          color: isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 16,
              color: isSelected ? activeColor : const Color(AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? activeColor : const Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.18) : const Color(0xFFEFF1F4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : const Color(AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
