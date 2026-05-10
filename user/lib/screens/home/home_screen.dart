import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Report Incident', Icons.gpp_bad_rounded, const Color(0x1AE63946), const Color(0xFFE63946)),
      ('Lost & Found', Icons.travel_explore_rounded, const Color(0x140085D0), const Color(AppColors.primaryDeeper)),
      ('Past Questions', Icons.auto_stories_rounded, const Color(0x1A60A5FA), const Color(0xFF2F80ED)),
      ('Opportunities', Icons.workspace_premium_rounded, const Color(0x1AB69CFF), const Color(0xFF7E57C2)),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFE3E8EE),
                  child: Icon(Icons.person, color: Color(AppColors.textSecondary)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, Abubakar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
                      Text('Good Morning!', style: TextStyle(color: Color(AppColors.textSecondary))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                  icon: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search anything...',
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(height: 20),
            const AppSectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 10),
            GridView.builder(
              itemCount: actions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.28,
              ),
              itemBuilder: (_, i) {
                final item = actions[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIconBadge(icon: item.$2, bgColor: item.$3, iconColor: item.$4, size: 40),
                        const Spacer(),
                        Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const AppSectionHeader(
              title: 'Recent Activity',
              trailing: Text('See all', style: TextStyle(color: Color(AppColors.primaryDeeper), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            const _ActivityTile(
              title: 'Theft reported at Old Site',
              subtitle: '5 mins ago',
              icon: Icons.notification_important_rounded,
              iconBg: Color(0x1AE63946),
              iconColor: Color(AppColors.danger),
            ),
            const SizedBox(height: 8),
            const _ActivityTile(
              title: 'Found ID Card',
              subtitle: 'Law Faculty - 1 hour ago',
              icon: Icons.badge_rounded,
              iconBg: Color(0x140085D0),
              iconColor: Color(AppColors.primaryDeeper),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: AppIconBadge(icon: icon, bgColor: iconBg, iconColor: iconColor, size: 38),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Color(AppColors.textSecondary))),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
