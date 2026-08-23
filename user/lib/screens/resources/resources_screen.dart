import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_data.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/past_question.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';
import '../common/async_state_view.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Academic Resources',
          style: TextStyle(
            color: Color(AppColors.textPrimary),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 10),
          // Featured Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(AppColors.primary),
                  const Color(AppColors.primaryDeeper),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primary).withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.sparkle, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'FEATURED TOOL',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Past Questions Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Prepare for exams with verified question papers cataloged by department, semester, and level.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(AppColors.primaryDeeper),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.pastQuestions),
                  icon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 16),
                  label: const Text('Start Searching', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppSectionHeader(title: 'Resource Category'),
          const SizedBox(height: 12),
          _resourceTile(context, 'Past Questions', 'Find past questions by course and department', PhosphorIconsRegular.fileText, const Color(AppColors.primaryDeeper), AppRoutes.pastQuestions),
          _resourceTile(context, 'FYP & SIWES Guidelines', 'Final Year Project structure and SIWES reports', PhosphorIconsRegular.bookBookmark, const Color(AppColors.primaryDeeper), AppRoutes.fypSiwes),
          _resourceTile(context, 'Student Handbook', 'University rules, policies and guidelines', PhosphorIconsRegular.bookOpen, const Color(AppColors.primaryDeeper), AppRoutes.studentHandbook),
          _resourceTile(context, 'Opportunities', 'Scholarships, Internships and more', PhosphorIconsRegular.graduationCap, const Color(AppColors.primaryDeeper), AppRoutes.opportunities),
          _resourceTile(context, 'E-Library', 'Access digital books and research materials', PhosphorIconsRegular.book, const Color(AppColors.primaryDeeper), AppRoutes.eLibrary),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _resourceTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    String routeName,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(AppColors.card),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFF1F4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060B1A2B),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, routeName),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon accent circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          color: Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
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
                const SizedBox(width: 8),
                // Trailing design
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: Color(AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PastQuestionsScreen extends StatefulWidget {
  const PastQuestionsScreen({super.key});

  @override
  State<PastQuestionsScreen> createState() => _PastQuestionsScreenState();
}

class _PastQuestionsScreenState extends State<PastQuestionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLevel;
  String? _selectedSemester;
  String? _selectedCourse;

  static final List<PastQuestion> _dummyPastQuestions = [
    PastQuestion(
      id: 'dummy_1',
      title: 'CSC 202 - Data Structures Exam 2024',
      faculty: 'Computing',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '200 Level',
      semester: 'First Semester',
      course: 'Data Structures (CSC 202)',
      fileUrl: 'https://example.com/dummy.pdf',
      fileSize: '1.2 MB',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    PastQuestion(
      id: 'dummy_2',
      title: 'CSC 301 - Algorithms & Complexity 2023',
      faculty: 'Computing',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      semester: 'Second Semester',
      course: 'Algorithms (CSC 301)',
      fileUrl: 'https://example.com/dummy.pdf',
      fileSize: '950 KB',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    PastQuestion(
      id: 'dummy_3',
      title: 'MTH 101 - Calculus & Algebra 2024',
      faculty: 'Science',
      department: 'Mathematical Sciences',
      program: 'B.Sc. Mathematics',
      level: '100 Level',
      semester: 'First Semester',
      course: 'Calculus (MTH 101)',
      fileUrl: 'https://example.com/dummy.pdf',
      fileSize: '2.1 MB',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    PastQuestion(
      id: 'dummy_4',
      title: 'CSC 401 - Artificial Intelligence 2023',
      faculty: 'Computing',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '400 Level',
      semester: 'First Semester',
      course: 'Artificial Intelligence (CSC 401)',
      fileUrl: 'https://example.com/dummy.pdf',
      fileSize: '1.8 MB',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    PastQuestion(
      id: 'dummy_5',
      title: 'GST 111 - Communication in English 2024',
      faculty: 'Arts',
      department: 'General Studies',
      program: 'All Programs',
      level: '100 Level',
      semester: 'First Semester',
      course: 'Communication (GST 111)',
      fileUrl: 'https://example.com/dummy.pdf',
      fileSize: '650 KB',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PastQuestion(
      id: 'dummy_6',
      title: 'CSC 204 - Object Oriented Programming 2023',
      faculty: 'Computing',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '200 Level',
      semester: 'Second Semester',
      course: 'Object Oriented Programming (CSC 204)',
      fileUrl: 'https://example.com/dummy.pdf',
      fileSize: '1.4 MB',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterOptions({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEFF1F4)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    final isSel = opt == selected;
                    return ListTile(
                      title: Text(
                        opt,
                        style: TextStyle(
                          color: isSel ? const Color(AppColors.primaryDeeper) : const Color(AppColors.textPrimary),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14.5,
                        ),
                      ),
                      trailing: isSel
                          ? const Icon(PhosphorIconsRegular.check, color: Color(AppColors.primaryDeeper), size: 18)
                          : null,
                      onTap: () {
                        onSelected(opt);
                        Navigator.pop(context);
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

  Widget _buildFilterPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(AppColors.primaryDeeper).withOpacity(0.08) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(AppColors.primaryDeeper).withOpacity(0.2) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(AppColors.primaryDeeper) : const Color(AppColors.textSecondary),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              PhosphorIconsRegular.caretDown,
              size: 12,
              color: isActive ? const Color(AppColors.primaryDeeper) : const Color(AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, PastQuestion paper) {
    final courseText = paper.course;
    String code = '';
    String title = paper.title.isEmpty ? courseText : paper.title;

    final match = RegExp(r'\((.*?)\)').firstMatch(courseText);
    if (match != null && match.groupCount >= 1) {
      code = match.group(1)!;
      if (title.contains(code)) {
        title = title.replaceAll('($code)', '').trim();
      }
    } else {
      code = courseText.split(' ').last;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F4)),
        boxShadow: const [
          BoxShadow(color: Color(0x020B1A2B), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.fileText,
                          color: Color(AppColors.primaryDeeper),
                          size: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: Color(AppColors.textPrimary),
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${paper.level} • ${paper.semester == "First Semester" ? "1st Sem" : "2nd Sem"}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(AppColors.textSecondary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEFF1F4)),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${paper.title.isEmpty ? paper.course : paper.title}')),
              );
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    PhosphorIconsRegular.download,
                    color: Color(AppColors.primaryDeeper),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Download (${paper.fileSize})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryDeeper),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Past Questions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PastQuestion>>(
        stream: context.read<FirestoreService>().allPastQuestions(),
        builder: (context, snapshot) {
          var papers = snapshot.data ?? const <PastQuestion>[];
          if (papers.isEmpty) {
            papers = _dummyPastQuestions;
          }

          // Dynamic unique courses from fetched data
          final uniqueCourses = papers.map((p) => p.course).toSet().toList();

          // Local matching logic
          final query = _searchQuery.toLowerCase().trim();
          final filtered = papers.where((paper) {
            final matchesSearch = query.isEmpty ||
                paper.title.toLowerCase().contains(query) ||
                paper.course.toLowerCase().contains(query) ||
                paper.department.toLowerCase().contains(query) ||
                paper.program.toLowerCase().contains(query);

            final matchesLevel = _selectedLevel == null || paper.level == _selectedLevel;
            final matchesSemester = _selectedSemester == null || paper.semester == _selectedSemester;
            final matchesCourse = _selectedCourse == null || paper.course == _selectedCourse;

            return matchesSearch && matchesLevel && matchesSemester && matchesCourse;
          }).toList();

          return AsyncStateView(
            connectionState: snapshot.connectionState,
            hasError: snapshot.hasError,
            errorMessage: snapshot.error?.toString(),
            isEmpty: papers.isEmpty,
            emptyMessage: 'No uploaded past questions found.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF1F4)),
                      boxShadow: const [
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
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Search course, code, or title...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13.5,
                        ),
                        prefixIcon: const Icon(
                          PhosphorIconsRegular.magnifyingGlass,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(PhosphorIconsRegular.xCircle, size: 20, color: Color(0xFF94A3B8)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // 2. Horizontal filter pills
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          label: _selectedSemester ?? 'All Semesters',
                          isActive: _selectedSemester != null,
                          onTap: () => _showFilterOptions(
                            title: 'Select Semester',
                            options: const ['All Semesters', 'First Semester', 'Second Semester'],
                            selected: _selectedSemester ?? 'All Semesters',
                            onSelected: (val) {
                              setState(() {
                                _selectedSemester = val == 'All Semesters' ? null : val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label: _selectedLevel ?? 'All Levels',
                          isActive: _selectedLevel != null,
                          onTap: () => _showFilterOptions(
                            title: 'Select Level',
                            options: const ['All Levels', '100 Level', '200 Level', '300 Level', '400 Level', '500 Level', '600 Level'],
                            selected: _selectedLevel ?? 'All Levels',
                            onSelected: (val) {
                              setState(() {
                                _selectedLevel = val == 'All Levels' ? null : val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label: _selectedCourse ?? 'All Courses',
                          isActive: _selectedCourse != null,
                          onTap: () {
                            final list = ['All Courses', ...uniqueCourses];
                            _showFilterOptions(
                              title: 'Select Course',
                              options: list,
                              selected: _selectedCourse ?? 'All Courses',
                              onSelected: (val) {
                                setState(() {
                                  _selectedCourse = val == 'All Courses' ? null : val;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Grid of matched documents
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(PhosphorIconsRegular.funnel, size: 48, color: Color(0xFF94A3B8)),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Matches Found',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(AppColors.textPrimary)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'No past questions meet the selected criteria. Try revising your search or filters.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: const Color(AppColors.textSecondary), height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildQuestionCard(context, filtered[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StudentHandbookScreen extends StatelessWidget {
  const StudentHandbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderResource(title: 'Student Handbook');
  }
}

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderResource(title: 'Opportunities');
  }
}

class ELibraryScreen extends StatelessWidget {
  const ELibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderResource(title: 'E-Library');
  }
}

class _PlaceholderResource extends StatelessWidget {
  const _PlaceholderResource({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title content goes here.')));
  }
}

class FypSiwesScreen extends StatefulWidget {
  const FypSiwesScreen({super.key});

  @override
  State<FypSiwesScreen> createState() => _FypSiwesScreenState();
}

class _FypSiwesScreenState extends State<FypSiwesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Color(AppColors.textPrimary)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Project & SIWES Guidelines',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(AppColors.primaryDeeper),
          unselectedLabelColor: const Color(AppColors.textSecondary),
          indicatorColor: const Color(AppColors.primaryDeeper),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'FYP Guidelines'),
            Tab(text: 'SIWES Guidelines'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFypSection(),
          _buildSiwesSection(),
        ],
      ),
    );
  }

  Widget _buildFypSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Project Structure',
          icon: PhosphorIconsRegular.listNumbers,
          description: 'A standard Final Year Project (FYP) report consists of 5 core chapters:',
          bullets: const [
            'Chapter 1: Introduction (Background, Problem Statement, Objectives, Scope).',
            'Chapter 2: Literature Review (Theoretical framework, Review of related works).',
            'Chapter 3: System Methodology & Design (Analysis, System architecture, UML, Flowcharts).',
            'Chapter 4: Implementation & Results (Coding, Testing, Evaluation, Screenshots).',
            'Chapter 5: Conclusion & Recommendations (Summary of accomplishments, Future upgrades).',
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Formatting Guidelines',
          icon: PhosphorIconsRegular.textAa,
          description: 'Ensure strict compliance with the following standard parameters before submission:',
          bullets: const [
            'Font Style: Times New Roman, Size 12 for body text, 14 bold for subheadings.',
            'Line Spacing: 2.0 (Double spaced) or 1.5 spacing, single-sided printing.',
            'Margins: Left margin 1.5 inches (for binding space), other margins 1.0 inch.',
            'Reference Style: APA 7th Edition or Harvard citation style is mandatory.',
            'Page Limits: Typically 50 to 90 pages depending on project scope.',
          ],
        ),
        const SizedBox(height: 16),
        _buildDownloadTile(
          title: 'Final Year Project Template',
          subtitle: 'Microsoft Word template with pre-configured styles (.docx)',
          size: '480 KB',
          onTap: () => _mockDownload(context, 'Final Year Project Template.docx'),
        ),
      ],
    );
  }

  Widget _buildSiwesSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'SIWES Logbook Rules',
          icon: PhosphorIconsRegular.bookBookmark,
          description: 'Keep your SIWES logbook neat and verify submissions using these parameters:',
          bullets: const [
            'Daily Recording: Fill in your work activities day-by-day directly in the logbook.',
            'Weekly Summary: Write structured summaries at the end of each training week.',
            'Sketches/Diagrams: Draw explanatory flowcharts or drawings of the machinery/software used.',
            'Supervisor Signatures: Ensure your industry supervisor stamps and dates your entries weekly.',
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'SIWES Technical Report',
          icon: PhosphorIconsRegular.fileText,
          description: 'Submit your typed SIWES report within 2 weeks of resuming containing:',
          bullets: const [
            'Introduction & Organizational Profile (Brief profile of company/agency).',
            'Detailed operations and activities carried out (Specific roles and jobs executed).',
            'Technical problems encountered and solutions/recommendations proposed.',
            'Conclusion & critical assessment of training value.',
          ],
        ),
        const SizedBox(height: 16),
        _buildDownloadTile(
          title: 'SIWES Report Structure Guide',
          subtitle: 'A detailed manual outlining the formatting and structure of SIWES reports (.pdf)',
          size: '1.5 MB',
          onTap: () => _mockDownload(context, 'SIWES Report Structure Guide.pdf'),
        ),
        const SizedBox(height: 8),
        _buildDownloadTile(
          title: 'Sample SIWES Logbook Entry',
          subtitle: 'Pre-filled sample pages showing standard descriptions (.pdf)',
          size: '820 KB',
          onTap: () => _mockDownload(context, 'Sample SIWES Logbook.pdf'),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String description,
    required List<String> bullets,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFF1F4)),
        boxShadow: const [
          BoxShadow(color: Color(0x020B1A2B), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(AppColors.primaryDeeper), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(AppColors.textPrimary),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...bullets.map((bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(PhosphorIconsFill.circle, size: 5, color: Color(AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(AppColors.textSecondary),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDownloadTile({
    required String title,
    required String subtitle,
    required String size,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(PhosphorIconsRegular.downloadSimple, color: Color(AppColors.primaryDeeper), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: Color(AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  size,
                  style: const TextStyle(fontSize: 11, color: Color(AppColors.textSecondary), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mockDownload(BuildContext context, String filename) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading $filename...')),
    );
  }
}
