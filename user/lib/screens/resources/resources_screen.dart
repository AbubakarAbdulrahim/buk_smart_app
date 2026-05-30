import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_widgets.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _resourceTile(context, 'Past Questions', 'Find past questions by course and department', Icons.description_outlined, const Color(0x1A30D5C8), AppRoutes.pastQuestions),
          const SizedBox(height: 10),
          _resourceTile(context, 'Student Handbook', 'University rules, policies and guidelines', Icons.menu_book_outlined, const Color(0x1AFF8A65), AppRoutes.studentHandbook),
          const SizedBox(height: 10),
          _resourceTile(context, 'Opportunities', 'Scholarships, Internships and more', Icons.school_outlined, const Color(0x1AB69CFF), AppRoutes.opportunities),
          const SizedBox(height: 10),
          _resourceTile(context, 'E-Library', 'Access digital books and research materials', Icons.local_library_outlined, const Color(0x1A60A5FA), AppRoutes.eLibrary),
          const SizedBox(height: 16),
          AppButton(label: 'Open BUK Bot', onPressed: () => Navigator.pushNamed(context, AppRoutes.chatbot)),
        ],
      ),
    );
  }

  Widget _resourceTile(BuildContext context, String title, String subtitle, IconData icon, Color bg, String routeName) {
    return SectionCard(
      child: ListTile(
        minVerticalPadding: 10,
        contentPadding: EdgeInsets.zero,
        onTap: () => Navigator.pushNamed(context, routeName),
        leading: AppIconBadge(icon: icon, bgColor: bg, iconColor: const Color(AppColors.primaryDeeper)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
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
  String faculty = 'Faculty of Computer Science';
  String department = 'Computer Science';
  String program = 'B.Sc. Computer Science';
  String course = 'Data Structures (CSC 202)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Questions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _drop('Select Faculty', faculty, const ['Faculty of Computer Science', 'Faculty of Arts'], (v) => setState(() => faculty = v!)),
          _drop('Select Department', department, const ['Computer Science', 'Information Technology'], (v) => setState(() => department = v!)),
          _drop('Select Program', program, const ['B.Sc. Computer Science', 'B.Sc. IT'], (v) => setState(() => program = v!)),
          _drop('Select Course', course, const ['Data Structures (CSC 202)', 'Algorithms (CSC 301)'], (v) => setState(() => course = v!)),
          const SizedBox(height: 14),
          const AppSectionHeader(title: 'Available Papers'),
          const SizedBox(height: 10),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIconBadge(icon: Icons.picture_as_pdf_outlined),
                  title: Text('202${3 - index} (Final)', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('PDF • 2.1 MB'),
                  trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drop(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
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

