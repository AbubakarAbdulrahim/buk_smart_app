import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../lost_found/lost_found_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_incident_screen.dart';
import '../resources/resources_screen.dart';
import 'home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _screens = const [
    HomeScreen(),
    ReportIncidentScreen(),
    LostFoundScreen(),
    ResourcesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0x1F0085D0),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
              color: states.contains(WidgetState.selected) ? const Color(AppColors.primaryDeeper) : const Color(AppColors.textSecondary),
            ),
          ),
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          elevation: 3,
          selectedIndex: _index,
          onDestinationSelected: (i) {
            HapticFeedback.selectionClick();
            setState(() => _index = i);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_filled), selectedIcon: Icon(Icons.home_filled), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.report_gmailerrorred_rounded), selectedIcon: Icon(Icons.report_rounded), label: 'Report'),
            NavigationDestination(icon: Icon(Icons.manage_search_rounded), selectedIcon: Icon(Icons.manage_search_rounded), label: 'Lost & Found'),
            NavigationDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books_rounded), label: 'Resources'),
            NavigationDestination(icon: Icon(Icons.account_circle_outlined), selectedIcon: Icon(Icons.account_circle_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
