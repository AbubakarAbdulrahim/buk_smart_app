import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/campus_updates_provider.dart';

class CampusUpdatesScreen extends StatefulWidget {
  const CampusUpdatesScreen({super.key});

  @override
  State<CampusUpdatesScreen> createState() => _CampusUpdatesScreenState();
}

class _CampusUpdatesScreenState extends State<CampusUpdatesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Seminar', 'Lecture', 'Campus Update'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(String updateId) {
    Navigator.pushNamed(
      context,
      AppRoutes.campusUpdateDetail,
      arguments: updateId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Campus Updates',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CampusUpdatesProvider>(
        builder: (context, provider, child) {
          // Filter and search updates
          final allFiltered = provider.updates.where((u) {
            final matchesCategory = _selectedCategory == 'All' || u.tag == _selectedCategory;
            final matchesSearch = u.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.content.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCategory && matchesSearch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar Widget
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(AppColors.darkBorder)
                          : const Color(AppColors.border),
                    ),
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? []
                        : const [
                            BoxShadow(
                              color: Color(0x040D1B2D),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(AppColors.darkTextPrimary)
                          : const Color(AppColors.textPrimary),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: 'Search updates, events or announcements...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(AppColors.darkTextSecondary)
                            : const Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        PhosphorIconsRegular.magnifyingGlass,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(AppColors.darkTextSecondary)
                            : const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                PhosphorIconsRegular.xCircle,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(AppColors.darkTextSecondary)
                                    : const Color(0xFF94A3B8),
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. Sliding Filter Chips
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(AppColors.primary) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border)),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(AppColors.primary).withOpacity(0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Main Announcements List
              Expanded(
                child: allFiltered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: allFiltered.length,
                        itemBuilder: (context, index) {
                          final update = allFiltered[index];
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          // Render the first item as a beautiful featured card (if not searching)
                          if (index == 0 && _searchQuery.isEmpty) {
                            return _buildFeaturedCard(update);
                          }
                          
                          // Prepend section title for normal list items
                          if (index == 1 && _searchQuery.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 8),
                                  child: Text(
                                    'Recent Updates',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                                _buildFeedCard(update),
                              ],
                            );
                          }

                          return _buildFeedCard(update);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Previews the highest priority announcement in style
  Widget _buildFeaturedCard(CampusUpdate update) {
    final readingTime = '${update.content.split(' ').length ~/ 150 + 1} min read';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: update.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: update.gradient.first.withOpacity(0.24),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _navigateToDetail(update.id),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Icon(
                  update.icon,
                  size: 130,
                  color: Colors.white.withOpacity(0.09),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIconsRegular.star,
                                color: Colors.white,
                                size: 11,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            readingTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      update.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.calendarBlank,
                          color: Color(0xFFF1F5F9),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          update.date,
                          style: const TextStyle(
                            color: Color(0xFFF1F5F9),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Read News',
                                style: TextStyle(
                                  color: Color(AppColors.primary),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                PhosphorIconsRegular.caretRight,
                                color: Color(AppColors.primary),
                                size: 12,
                              ),
                            ],
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
    );
  }

  // Renders beautiful, optimized item cards in the feed list
  Widget _buildFeedCard(CampusUpdate update) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readingTime = '${update.content.split(' ').length ~/ 150 + 1} min read';
    final totalReactions = update.reactions.values.fold(0, (sum, val) => sum + val);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(AppColors.darkBorder)
              : const Color(AppColors.border),
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Color(0x040D1B2D),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _navigateToDetail(update.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: update.gradient.first.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        update.tag,
                        style: TextStyle(
                          color: update.gradient.first,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      readingTime,
                      style: TextStyle(
                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  update.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  update.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark
                      ? const Color(AppColors.darkBorder)
                      : const Color(0xFFEFF1F4),
                  height: 1,
                ),
                const SizedBox(height: 10),
                Row(
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (totalReactions > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(AppColors.darkCardSubtle)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            ...update.reactions.entries
                                .where((e) => e.value > 0)
                                .take(3)
                                .map((e) => Text(e.key, style: const TextStyle(fontSize: 11))),
                            const SizedBox(width: 4),
                            Text(
                              '$totalReactions',
                              style: TextStyle(
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  // Premium, informative empty state representation
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.binoculars,
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Updates Found',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any announcements matching your current category filter or search query. Try clearing your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
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
