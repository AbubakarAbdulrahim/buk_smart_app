import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../lost_found/lost_found_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
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
    MapScreen(),
    LostFoundScreen(),
    ResourcesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(AppColors.darkBackground) : const Color(AppColors.background),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(AppColors.darkBorder).withOpacity(0.6)
                  : const Color(AppColors.border).withOpacity(0.8),
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: isDark ? const Color(0x3D0085D0) : const Color(0x1F0085D0),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper))
                    : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper))
                    : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
              ),
            ),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: isDark ? const Color(AppColors.darkBackground) : const Color(AppColors.background),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _index,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              setState(() => _index = i);
            },
            destinations: const [
              NavigationDestination(icon: Icon(PhosphorIconsRegular.house), selectedIcon: Icon(PhosphorIconsRegular.house), label: 'Home'),
              NavigationDestination(icon: Icon(PhosphorIconsRegular.mapTrifold), selectedIcon: Icon(PhosphorIconsRegular.mapTrifold), label: 'Map'),
              NavigationDestination(icon: Icon(PhosphorIconsRegular.magnifyingGlass), selectedIcon: Icon(PhosphorIconsRegular.magnifyingGlass), label: 'Lost & Found'),
              NavigationDestination(icon: Icon(PhosphorIconsRegular.bookOpen), selectedIcon: Icon(PhosphorIconsRegular.bookOpen), label: 'Resources'),
              NavigationDestination(icon: Icon(PhosphorIconsRegular.user), selectedIcon: Icon(PhosphorIconsRegular.user), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
