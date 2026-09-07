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

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key, this.openPost = false});

  final bool openPost;

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedType = 'All'; // 'All', 'lost', 'found'
  String _selectedTimeFilter = 'All'; // 'All', 'Today', 'This Week'
  final TextEditingController _searchController = TextEditingController();

  // Categories definition
  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Student ID', 'emoji': '🪪', 'icon': PhosphorIconsRegular.identificationCard, 'color': Color(0xFF3B82F6)},
    {'name': 'Bags', 'emoji': '🎒', 'icon': PhosphorIconsRegular.backpack, 'color': Color(0xFFF59E0B)},
    {'name': 'Phones', 'emoji': '📱', 'icon': PhosphorIconsRegular.deviceMobile, 'color': Color(0xFF10B981)},
    {'name': 'Laptop', 'emoji': '💻', 'icon': PhosphorIconsRegular.laptop, 'color': Color(0xFF8B5CF6)},
    {'name': 'Documents', 'emoji': '📄', 'icon': PhosphorIconsRegular.fileText, 'color': Color(0xFF6366F1)},
    {'name': 'Keys', 'emoji': '🔑', 'icon': PhosphorIconsRegular.key, 'color': Color(0xFFEC4899)},
    {'name': 'Wallet', 'emoji': '💳', 'icon': PhosphorIconsRegular.creditCard, 'color': Color(0xFFEF4444)},
    {'name': 'Clothing', 'emoji': '👕', 'icon': PhosphorIconsRegular.tShirt, 'color': Color(0xFF14B8A6)},
    {'name': 'Books', 'emoji': '📚', 'icon': PhosphorIconsRegular.bookOpen, 'color': Color(0xFFF97316)},
    {'name': 'Accessories', 'emoji': '🎧', 'icon': PhosphorIconsRegular.headphones, 'color': Color(0xFF06B6D4)},
    {'name': 'Others', 'emoji': '📦', 'icon': PhosphorIconsRegular.cube, 'color': Color(0xFF64748B)},
  ];

  // Quick filters combining category tags and status types
  final List<String> _quickFilters = const [
    'All',
    'Lost',
    'Found',
    'Today',
    'This Week',
    'ID Cards',
    'Electronics',
    'Bags',
    'Documents',
    'Keys',
    'Clothing',
    'Others',
  ];
  
  String _activeQuickFilter = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.openPost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, AppRoutes.lostFoundWizard);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      _activeQuickFilter = filter;
      if (filter == 'All') {
        _selectedType = 'All';
        _selectedTimeFilter = 'All';
        _selectedCategory = 'All';
      } else if (filter == 'Lost') {
        _selectedType = 'lost';
        _selectedTimeFilter = 'All';
        _selectedCategory = 'All';
      } else if (filter == 'Found') {
        _selectedType = 'found';
        _selectedTimeFilter = 'All';
        _selectedCategory = 'All';
      } else if (filter == 'Today') {
        _selectedTimeFilter = 'Today';
        _selectedType = 'All';
        _selectedCategory = 'All';
      } else if (filter == 'This Week') {
        _selectedTimeFilter = 'This Week';
        _selectedType = 'All';
        _selectedCategory = 'All';
      } else {
        // Map clean names to database categories
        _selectedCategory = filter == 'ID Cards' ? 'Student ID' : filter;
        _selectedType = 'All';
        _selectedTimeFilter = 'All';
      }
    });
  }

  bool _passesTimeFilter(DateTime createdAt) {
    if (_selectedTimeFilter == 'All') return true;
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    if (_selectedTimeFilter == 'Today') {
      return difference == 0 && now.day == createdAt.day;
    }
    if (_selectedTimeFilter == 'This Week') {
      return difference <= 7;
    }
    return true;
  }

  Color _getCategoryColor(String name) {
    final match = _categories.firstWhere(
      (c) => c['name'].toString().toLowerCase() == name.toLowerCase(),
      orElse: () => {'color': const Color(0xFF64748B)},
    );
    return match['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final auth = context.read<AuthService>();
    final currentUid = auth.currentUser?.uid ?? 'guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(AppColors.primary),
        elevation: 4,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.lostFoundWizard);
        },
        icon: const Icon(PhosphorIconsRegular.plus, color: Colors.white, size: 20),
        label: const Text(
          'Report Item',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. High fidelity Search Bar & Bookmarks
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
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
                        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Search ID card, laptop, phone, wallet, bag...',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          PhosphorIconsRegular.magnifyingGlass,
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  PhosphorIconsRegular.xCircle,
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF94A3B8),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.lostFoundBookmarks);
                  },
                  child: Container(
                    height: 52,
                    width: 52,
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
                              BoxShadow(
                                color: Color(0x040D1B2D),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIconsRegular.bookmarkSimple,
                        color: isDark
                            ? const Color(AppColors.darkTextPrimary)
                            : const Color(AppColors.textPrimary),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

            // 3. Sliding filter chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _quickFilters.length,
                itemBuilder: (context, index) {
                  final filter = _quickFilters[index];
                  final isSelected = _activeQuickFilter == filter;
                  return GestureDetector(
                    onTap: () => _applyQuickFilter(filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(AppColors.primary)
                            : (isDark ? const Color(AppColors.darkCardSubtle) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4)),
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
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. Categories list (Circular colorful icons)
            if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: Text(
                  'Browse Categories',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              SizedBox(
                height: 94,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isCategorySelected = _selectedCategory == cat['name'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['name'];
                          _activeQuickFilter = cat['name'] == 'Student ID' ? 'ID Cards' : cat['name'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 18),
                        child: Column(
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: isCategorySelected 
                                    ? const Color(AppColors.primary) 
                                    : (isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  cat['icon'] as IconData,
                                  color: isCategorySelected 
                                      ? Colors.white 
                                      : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isCategorySelected ? FontWeight.bold : FontWeight.w600,
                                color: isCategorySelected
                                    ? const Color(AppColors.primary)
                                    : (isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Item details header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    _selectedCategory == 'All' ? 'Recent Reports' : 'Category: $_selectedCategory',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != 'All' || _selectedType != 'All' || _searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () => _applyQuickFilter('All'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Reset Filters',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 6. Main stream builder feeding the list
            Expanded(
              child: StreamBuilder<List<LostFoundItem>>(
                stream: _selectedType == 'All'
                    ? firestore.allLostFound()
                    : firestore.lostFound(_selectedType),
                builder: (context, snapshot) {
                  final rawItems = snapshot.data ?? [];
                  
                  // Filter client side for category, search strings, time parameters
                  final items = rawItems.where((item) {
                    final passesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
                    
                    final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        item.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        item.category.toLowerCase().contains(_searchQuery.toLowerCase());
                    
                    return passesCategory && matchesSearch && _passesTimeFilter(item.createdAt);
                  }).toList();

                  // Sort strictly descending by createdAt to make recently posted items appear at the very top
                  items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return AsyncStateView(
                    connectionState: snapshot.connectionState,
                    hasError: snapshot.hasError,
                    errorMessage: snapshot.error?.toString(),
                    isEmpty: items.isEmpty,
                    emptyWidget: _buildEmptyState(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        return _buildItemCard(context, item, currentUid, firestore);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  // Airbnb style Premium Item Card representation
  Widget _buildItemCard(
    BuildContext context,
    LostFoundItem item,
    String currentUid,
    FirestoreService firestore,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLost = item.type == 'lost';
    final isBookmarked = item.bookmarkedBy.contains(currentUid);
    final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
    final formattedTime = DateFormat('h:mm a').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Color(0x030F172A),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.lostFoundDetail,
              arguments: item.id,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Area (16:9 ratio)
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                            child: Center(
                              child: Icon(
                                PhosphorIconsRegular.image,
                                size: 40,
                                color: isDark
                                    ? const Color(AppColors.darkTextSecondary).withOpacity(0.5)
                                    : const Color(AppColors.textSecondary).withOpacity(0.5),
                              ),
                            ),
                          ),
                  ),

                  // Bookmark Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(AppColors.darkCard) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isBookmarked ? PhosphorIconsFill.bookmark : PhosphorIconsRegular.bookmarkSimple,
                          color: isBookmarked
                              ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary))
                              : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                          size: 18,
                        ),
                        onPressed: () async {
                          if (currentUid == 'guest') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in to save bookmarks.')),
                            );
                            return;
                          }
                          await firestore.toggleBookmark(item.id, currentUid);
                        },
                      ),
                    ),
                  ),

                  // Positioned pills
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      children: [
                        // Status badge (Lost/Found)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isLost
                                ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isLost
                                  ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
                                  : (isDark ? const Color(0xFF047857) : const Color(0xFF6EE7B7)),
                            ),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color: isLost
                                  ? (isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C))
                                  : (isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF047857)),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Category Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Title and Description
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFF1F5F9),
                      height: 1,
                    ),
                    const SizedBox(height: 12),

                    // Location & Reporter block
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.mapPin,
                                    color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.clock,
                                    color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$formattedDate • $formattedTime',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Reporter verification status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(AppColors.darkCardSubtle)
                                : (item.isVerified ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.isVerified ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.userCircle,
                                color: item.isVerified
                                    ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary))
                                    : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item.isVerified ? 'VERIFIED' : 'STUDENT',
                                style: TextStyle(
                                  color: item.isVerified
                                      ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary))
                                      : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
                                  fontSize: 8.5,
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
            ],
          ),
        ),
      ),
    );
  }

  // Modern empty state illustrations
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.magnifyingGlass,
                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No items found',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Everything seems to have been claimed! 🎉 Try searching for another item or adjust your quick filter selections.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
