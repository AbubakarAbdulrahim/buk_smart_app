import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/campus_updates_provider.dart';

class CampusUpdateDetailScreen extends StatefulWidget {
  const CampusUpdateDetailScreen({
    super.key,
    required this.updateId,
  });

  final String updateId;

  @override
  State<CampusUpdateDetailScreen> createState() => _CampusUpdateDetailScreenState();
}

class _CampusUpdateDetailScreenState extends State<CampusUpdateDetailScreen> with SingleTickerProviderStateMixin {
  bool _showEmojiPicker = false;
  late AnimationController _pickerController;
  late Animation<double> _pickerScale;

  final List<String> _emojis = const ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  @override
  void initState() {
    super.initState();
    _pickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pickerScale = CurvedAnimation(
      parent: _pickerController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        _pickerController.forward();
      } else {
        _pickerController.reverse();
      }
    });
  }

  void _submitReaction(String emoji, CampusUpdatesProvider provider) {
    provider.toggleReaction(widget.updateId, emoji);
    setState(() {
      _showEmojiPicker = false;
      _pickerController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CampusUpdatesProvider>(
      builder: (context, provider, child) {
        final updates = provider.updates;
        final updateIdx = updates.indexWhere((u) => u.id == widget.updateId);

        if (updateIdx == -1) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text(
                'Announcement not found.',
                style: TextStyle(color: Color(AppColors.textSecondary)),
              ),
            ),
          );
        }

        final update = updates[updateIdx];
        final readingTime = '${update.content.split(' ').length ~/ 150 + 1} min read';
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Filter and sort active reactions
        final sortedReactions = update.reactions.entries
            .where((cnt) => cnt.value > 0)
            .toList();

        final totalReactions = update.reactions.values
            .fold(0, (sum, val) => sum + val);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              update.tag,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Article Hero Title Banner
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: update.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: update.gradient.first.withOpacity(0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -24,
                              top: -24,
                              child: Icon(
                                update.icon,
                                size: 140,
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          update.tag.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    update.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    update.subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFFF1F5F9),
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Publication metadata block
                    Row(
                      children: [
                        // Date Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIconsRegular.calendarBlank,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                update.date,
                                style: TextStyle(
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reading Time Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIconsRegular.clock, color: update.gradient.first, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                readingTime,
                                style: TextStyle(
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. Message Details Main block
                    Text(
                      'ANNOUNCEMENT BRIEF',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                        ),
                        boxShadow: isDark
                            ? []
                            : const [
                                BoxShadow(
                                  color: Color(0x020D1B2D),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Text(
                        update.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 4. Reactions Summary block
                    if (totalReactions > 0) ...[
                      Text(
                        'COMMUNITY REACTIONS',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sortedReactions.map((entry) {
                          final emoji = entry.key;
                          final count = entry.value;
                          final isUserRep = update.userReaction == emoji;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isUserRep
                                  ? (isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF))
                                  : (isDark ? const Color(AppColors.darkCardSubtle) : Theme.of(context).cardColor),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUserRep
                                    ? (isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE))
                                    : (isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border)),
                                width: 1,
                              ),
                              boxShadow: isDark
                                  ? []
                                  : const [
                                      BoxShadow(
                                        color: Color(0x020D1B2D),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 5),
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    color: isUserRep
                                        ? const Color(AppColors.primary)
                                        : (isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary)),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // 5. Floating Picker scale overlay
              if (_showEmojiPicker)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 74,
                  child: ScaleTransition(
                    scale: _pickerScale,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A0F172A),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _emojis.map((emoji) {
                            final isSelected = update.userReaction == emoji;
                            return GestureDetector(
                              onTap: () => _submitReaction(emoji, provider),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF))
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

              // 6. Styled bottom control trigger bar
              Positioned(
                key: const ValueKey('reaction-launcher-bar'),
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
                      ),
                    ),
                    boxShadow: isDark
                        ? []
                        : const [
                            BoxShadow(
                              color: Color(0x04000000),
                              blurRadius: 16,
                              offset: Offset(0, -4),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleEmojiPicker,
                          icon: Icon(
                            update.userReaction != null ? PhosphorIconsRegular.smiley : PhosphorIconsRegular.plus,
                            color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                            size: 16,
                          ),
                          label: Text(
                            update.userReaction != null
                                ? 'Reaction: ${update.userReaction}'
                                : 'Select Reaction',
                            style: TextStyle(
                              color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: update.userReaction != null
                                ? (isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF))
                                : Theme.of(context).cardColor,
                            side: BorderSide(
                              color: update.userReaction != null
                                  ? (isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE))
                                  : (isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border)),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
}
