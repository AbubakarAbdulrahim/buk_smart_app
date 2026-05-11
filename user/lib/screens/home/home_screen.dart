import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.94);
  int _currentPage = 0;

  final List<({
    String title,
    String subtitle,
    String tag,
    IconData icon,
    List<Color> gradient,
  })> _updates = const [
    (
      title: 'Faculty Seminar on AI Ethics',
      subtitle: 'Monday, 10:00 AM at CITS Hall. Open to all departments.',
      tag: 'Seminar',
      icon: Icons.campaign_rounded,
      gradient: [Color(0xFF0085D0), Color(0xFF39A9E6)],
    ),
    (
      title: 'Guest Lecture: Cybersecurity in Practice',
      subtitle: 'Join the industry session at Old Site Lecture Theatre by 2:00 PM.',
      tag: 'Lecture',
      icon: Icons.school_rounded,
      gradient: [Color(0xFF0E5E96), Color(0xFF0085D0)],
    ),
    (
      title: 'Students Week Registration Now Open',
      subtitle: 'Register before Friday for debates, sports, exhibitions, and awards.',
      tag: 'Campus Update',
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF004E7A), Color(0xFF0F79B9)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            const AppSectionHeader(title: 'Community Updates'),
            const SizedBox(height: 10),
            SizedBox(
              height: 164,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _updates.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final update = _updates[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: update.gradient,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x1A0B1A2B), blurRadius: 18, offset: Offset(0, 10)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    update.tag,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ),
                                const Spacer(),
                                Icon(update.icon, color: Colors.white, size: 24),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              update.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              update.subtitle,
                              style: const TextStyle(color: Color(0xFFEAF6FD), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _updates.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(AppColors.primaryDeeper) : const Color(0xFFD6E1EA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
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
