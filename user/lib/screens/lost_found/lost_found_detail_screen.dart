import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lost_found_item.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../common/async_state_view.dart';

class LostFoundDetailScreen extends StatefulWidget {
  const LostFoundDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<LostFoundDetailScreen> createState() => _LostFoundDetailScreenState();
}

class _LostFoundDetailScreenState extends State<LostFoundDetailScreen> {
  int _activeSliderPage = 0;
  final PageController _pageController = PageController();

  Color _getCategoryColor(String name) {
    const categories = {
      'student id': Color(0xFF3B82F6),
      'bags': Color(0xFFF59E0B),
      'phones': Color(0xFF10B981),
      'laptop': Color(0xFF8B5CF6),
      'documents': Color(0xFF6366F1),
      'keys': Color(0xFFEC4899),
      'wallet': Color(0xFFEF4444),
      'clothing': Color(0xFF14B8A6),
      'books': Color(0xFFF97316),
      'accessories': Color(0xFF06B6D4),
    };
    return categories[name.toLowerCase()] ?? const Color(0xFF64748B);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Contact Launcher handler
  Future<void> _contactReporter(LostFoundItem item) async {
    final channel = item.contactType ?? 'Show Name';
    final contactVal = item.contact;

    if (channel == 'Anonymous') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Anonymous listing', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'The reporter chose to remain anonymous. Please visit the Student Affairs office to inspect or verify this item.',
            style: TextStyle(height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    if (channel == 'Phone') {
      final cleanPhone = contactVal.replaceAll(RegExp(r'\s+'), '');
      final uri = Uri.parse('tel:$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showCopyDialog('Phone Number', contactVal);
      }
      return;
    }

    // Default to email/mailto
    if (channel == 'Email' || contactVal.contains('@')) {
      final uri = Uri.parse('mailto:$contactVal?subject=BUK%20Smart%20Lost%20Found%20Item');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showCopyDialog('Email Address', contactVal);
      }
      return;
    }

    // Fallback info dialog
    _showCopyDialog('Contact Info', contactVal);
  }

  void _showCopyDialog(String label, String value) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SelectableText(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Toggle flags status
  Future<void> _flagIncorrect(FirestoreService service) async {
    try {
      await service.reportIncorrectListing(widget.itemId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you! Listing reported to administrators.')),
      );
    } catch (e) {
      debugPrint('Error flagging item: $e');
    }
  }

  // Toggle item resolved state
  Future<void> _toggleClaimState(FirestoreService service, LostFoundItem item) async {
    setState(() {});
    try {
      // Toggle
      await service.updateLostFoundStatus(item.id, !item.isResolved);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(item.isResolved ? 'Marked as active listing.' : 'Success! Marked as Returned/Claimed. 🎉')),
      );
    } catch (e) {
      debugPrint('Error toggling claim status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final currentUid = auth.currentUser?.uid ?? 'guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<LostFoundItem>(
      stream: firestore.lostFoundItem(widget.itemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.primary)),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Details')),
            body: const Center(child: Text('Could not find listing details data.')),
          );
        }

        final item = snapshot.data!;
        final isBookmarked = item.bookmarkedBy.contains(currentUid);
        final isOwner = item.userId == currentUid;
        final images = item.imageUrls.isNotEmpty ? item.imageUrls : (item.imageUrl != null && item.imageUrl!.isNotEmpty ? [item.imageUrl!] : <String>[]);

        return Scaffold(
          body: Stack(
            children: [
              // Scrollable details contents
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carousel Header PageView (16:10 aspect ratio)
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 10,
                            child: images.isNotEmpty
                                ? PageView.builder(
                                    controller: _pageController,
                                    itemCount: images.length,
                                    onPageChanged: (page) {
                                      setState(() {
                                        _activeSliderPage = page;
                                      });
                                    },
                                    itemBuilder: (context, pageIdx) {
                                      return Image.network(
                                        images[pageIdx],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    },
                                  )
                                : Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: Center(
                                      child: Icon(
                                        PhosphorIconsRegular.image,
                                        size: 64,
                                        color: const Color(AppColors.textSecondary).withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                          ),

                          // Indicator Dots overlay
                          if (images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  images.length,
                                  (idx) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _activeSliderPage == idx ? 16 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _activeSliderPage == idx ? const Color(AppColors.primary) : Colors.white70,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                        // Document contents block
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges line
                            Row(
                              children: [
                                // Status type Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: item.type == 'lost'
                                        ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                                        : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: item.type == 'lost'
                                          ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
                                          : (isDark ? const Color(0xFF047857) : const Color(0xFF6EE7B7)),
                                    ),
                                  ),
                                  child: Text(
                                    item.type.toUpperCase(),
                                    style: TextStyle(
                                      color: item.type == 'lost'
                                          ? (isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C))
                                          : (isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF047857)),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Category Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(item.category).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getCategoryColor(item.category).withOpacity(0.24)),
                                  ),
                                  child: Text(
                                    item.category.toUpperCase(),
                                    style: TextStyle(
                                      color: _getCategoryColor(item.category),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const Spacer(),

                                // Date badge
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.calendarBlank,
                                      size: 14,
                                      color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy').format(item.createdAt),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Main Title
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Color / Brand pill metadata (Deliverable #4 Wizard results)
                            if (item.color != null || item.brand != null || item.uniqueFeatures != null) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (item.brand != null)
                                    _buildMetaChip(context, 'Brand: ${item.brand}', PhosphorIconsRegular.tag),
                                  if (item.color != null)
                                    _buildMetaChip(context, 'Color: ${item.color}', PhosphorIconsRegular.palette),
                                  if (item.uniqueFeatures != null)
                                    _buildMetaChip(context, 'Marking: ${item.uniqueFeatures}', PhosphorIconsRegular.fingerprint),
                                  if (item.isVerified)
                                    _buildMetaChip(context, 'Verified Student', PhosphorIconsRegular.shieldCheck, isPrimary: true),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Description block
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Location coordinate details
                            Text(
                              'Location Details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(AppColors.darkCard) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(AppColors.darkCardSubtle) : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      PhosphorIconsRegular.mapPin,
                                      color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Campus Coordinates',
                                          style: TextStyle(
                                            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.location,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Actions list card (Resolve state / flags incorrect)
                            _buildActionOptions(context, item, isOwner, firestore),
                            const SizedBox(height: 24),

                            // Similar items recommendations list (Smart Feature)
                            _buildSimilarItems(context, firestore, item),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Float Back Button on Top Left
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(AppColors.darkCard).withOpacity(0.9) : Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      PhosphorIconsRegular.arrowLeft,
                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Bottom control Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(AppColors.darkBackground)
                        : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(AppColors.darkBorder)
                            : const Color(AppColors.border),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Bookmarked icon
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(AppColors.darkCard)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(AppColors.darkBorder)
                                : Colors.transparent,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isBookmarked ? PhosphorIconsFill.bookmark : PhosphorIconsRegular.bookmarkSimple,
                            color: isBookmarked
                                ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary))
                                : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                          ),
                          onPressed: () async {
                            if (currentUid == 'guest') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Log in to bookmark items.')),
                              );
                              return;
                            }
                            await firestore.toggleBookmark(item.id, currentUid);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Contact / Claim Button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.isResolved ? const Color(0xFF94A3B8) : const Color(AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: item.isResolved ? null : () => _contactReporter(item),
                            icon: const Icon(PhosphorIconsRegular.paperPlaneTilt, color: Colors.white, size: 18),
                            label: Text(
                              item.isResolved
                                  ? 'Claimed / Resolved'
                                  : item.type == 'lost'
                                      ? 'Helper Found It?'
                                      : 'Claim Belonging',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Small metadata pills
  Widget _buildMetaChip(BuildContext context, String text, IconData icon, {bool isPrimary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? (isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isPrimary
                ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary))
                : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isPrimary
                  ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary))
                  : (isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary)),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Small action panel row (Claimed toggles / flag correctness)
  Widget _buildActionOptions(
    BuildContext context,
    LostFoundItem item,
    bool isOwner,
    FirestoreService firestore,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(AppColors.darkCard) : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
        ),
      ),
      child: Column(
        children: [
          if (isOwner)
            ListTile(
              dense: true,
              leading: Icon(
                item.isResolved ? PhosphorIconsRegular.arrowsLeftRight : PhosphorIconsRegular.check,
                color: item.isResolved ? Colors.orange : (isDark ? const Color(AppColors.darkSuccess) : Colors.green),
              ),
              title: Text(
                item.isResolved ? 'Mark Listing as Active' : 'Mark Listing as Resolved / Returned',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                ),
              ),
              subtitle: Text(
                item.isResolved ? 'Make item searchable again.' : 'Inform local students that this item has been matched.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
              ),
              onTap: () => _toggleClaimState(firestore, item),
            ),
          if (!isOwner)
            ListTile(
              dense: true,
              leading: Icon(
                PhosphorIconsRegular.flag,
                color: isDark ? const Color(AppColors.darkDanger) : Colors.redAccent,
              ),
              title: Text(
                'Report Incorrect Listing',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                ),
              ),
              subtitle: Text(
                'Report if this post contains fraudulent claims or fake photos.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
              ),
              onTap: () => _flagIncorrect(firestore),
            ),
        ],
      ),
    );
  }

  // Similar recommendation lists (Smart Feature)
  Widget _buildSimilarItems(BuildContext context, FirestoreService firestore, LostFoundItem targetItem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<LostFoundItem>>(
      stream: firestore.lostFound(targetItem.type),
      builder: (context, snapshot) {
        final matches = snapshot.data ?? [];
        // Filter elements in identical categories, excluding current item itself
        final similar = matches
            .where((m) => m.category == targetItem.category && m.id != targetItem.id)
            .take(3)
            .toList();

        if (similar.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could this be yours?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: similar.length,
              itemBuilder: (context, idx) {
                final match = similar[idx];
                return Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: match.imageUrl != null && match.imageUrl!.isNotEmpty
                          ? Image.network(match.imageUrl!, width: 44, height: 44, fit: BoxFit.cover)
                          : Container(
                              width: 44,
                              height: 44,
                              color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                              child: Icon(
                                PhosphorIconsRegular.image,
                                size: 18,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                    ),
                    title: Text(
                      match.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                      ),
                    ),
                    subtitle: Text(
                      match.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                      ),
                    ),
                    trailing: Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 16,
                      color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    ),
                    onTap: () {
                      // Navigate inside detail screen using replacement pushes
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.lostFoundDetail,
                        arguments: match.id,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
