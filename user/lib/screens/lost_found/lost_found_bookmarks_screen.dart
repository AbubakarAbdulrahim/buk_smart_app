import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lost_found_item.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../common/async_state_view.dart';

class LostFoundBookmarksScreen extends StatelessWidget {
  const LostFoundBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final currentUid = auth.currentUser?.uid ?? 'guest';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Bookmarks',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<LostFoundItem>>(
        stream: firestore.bookmarkedLostFound(currentUid),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          return AsyncStateView(
            connectionState: snapshot.connectionState,
            hasError: snapshot.hasError,
            errorMessage: snapshot.error?.toString(),
            isEmpty: items.isEmpty,
            emptyWidget: _buildEmptyState(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isLost = item.type == 'lost';
                final formattedDate = DateFormat('MMM dd, h:mm a').format(item.createdAt);

                return Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(item.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                          : Container(
                              width: 56,
                              height: 56,
                              color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                              child: Icon(
                                PhosphorIconsRegular.image,
                                size: 24,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLost
                                ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color: isLost
                                  ? (isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C))
                                  : (isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF047857)),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        PhosphorIconsFill.bookmark,
                        color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                        size: 20,
                      ),
                      onPressed: () async {
                        await firestore.toggleBookmark(item.id, currentUid);
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.lostFoundDetail,
                        arguments: item.id,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.bookmarkSimple,
              size: 54,
              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Items',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your bookmarked Lost & Found listings will appear here. Simply tap the bookmark icon on any item card.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
