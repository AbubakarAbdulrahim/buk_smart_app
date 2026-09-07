import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currentLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 1. PREFERENCES SECTION
          _buildSectionHeader('Preferences'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSwitchRow(
              label: 'Notifications',
              icon: PhosphorIconsRegular.bell,
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
            _buildValueRow(
              label: 'Theme Mode',
              icon: PhosphorIconsRegular.moon,
              value: _getThemeModeString(themeProvider.themeMode),
              onTap: () => _showThemeModeSelector(context, themeProvider),
            ),
            _buildValueRow(
              label: 'Language',
              icon: PhosphorIconsRegular.translate,
              value: _currentLanguage,
              onTap: _showLanguageSelector,
            ),
          ]),
          const SizedBox(height: 24),

          // 2. SECURITY SECTION
          _buildSectionHeader('Security'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildActionRow(
              label: 'Change Password',
              icon: PhosphorIconsRegular.lock,
              onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
            _buildActionRow(
              label: 'Two-Factor Authentication',
              icon: PhosphorIconsRegular.shieldCheck,
              onTap: _showTwoFactorSheet,
            ),
          ]),
          const SizedBox(height: 24),

          // 3. ABOUT SECTION
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildValueRow(
              label: 'App Version',
              icon: PhosphorIconsRegular.info,
              value: '1.0.0',
              onTap: () => _showAppVersionDialog(context),
            ),
            _buildActionRow(
              label: 'Terms of Service',
              icon: PhosphorIconsRegular.fileText,
              onTap: () => Navigator.pushNamed(context, AppRoutes.termsOfService),
            ),
            _buildActionRow(
              label: 'Privacy Policy',
              icon: PhosphorIconsRegular.shieldWarning,
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border),
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(color: Color(0x020B1A2B), blurRadius: 10, offset: Offset(0, 4)),
              ],
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFF1F5F9),
              indent: 52,
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(0xFF334155),
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
      ),
    );
  }

  Widget _buildValueRow({
    required String label,
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(0xFF334155),
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(0xFF334155),
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        PhosphorIconsRegular.caretRight,
        color: isDark ? const Color(AppColors.darkTextMuted) : const Color(0xFF94A3B8),
        size: 16,
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Select App Language',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.check, color: Color(AppColors.primaryDeeper)),
              title: const Text('English (Default)'),
              onTap: () {
                setState(() => _currentLanguage = 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Hausa'),
              onTap: () {
                setState(() => _currentLanguage = 'Hausa');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Arabic'),
              onTap: () {
                setState(() => _currentLanguage = 'Arabic');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showTwoFactorSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        maxChildSize: 0.6,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.shieldCheck,
                    color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Two-Factor Auth',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Protect your student account by verifying logins using an authentication code sent via SMS or email.',
                style: TextStyle(
                  height: 1.4,
                  fontSize: 13.5,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Two-factor auth preferences updated.')),
                    );
                  },
                  child: const Text('Enable Security Lock', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppVersionDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(AppColors.darkCard) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/buk_logo.png',
                width: 54,
                height: 54,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.graduationCap,
                    color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'SmartBUK Student App',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0 (Build 100)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.checkCircle,
                      size: 14,
                      color: isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'App is up to date',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What\'s New:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildChangelogItem('• Smart AI Assistant 24/7 student companion', isDark),
              _buildChangelogItem('• Real-time Incident Reporting with Photos', isDark),
              _buildChangelogItem('• Interactive Lost & Found Marketplace', isDark),
              _buildChangelogItem('• Comprehensive Dark Mode Support', isDark),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checking for updates... You have the latest version!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Check for Updates',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangelogItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeModeSelector(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Select Theme Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                PhosphorIconsRegular.desktop,
                color: themeProvider.themeMode == ThemeMode.system ? const Color(AppColors.primaryDeeper) : null,
              ),
              title: const Text('System Default'),
              trailing: themeProvider.themeMode == ThemeMode.system
                  ? const Icon(PhosphorIconsRegular.check, color: Color(AppColors.primaryDeeper))
                  : null,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                PhosphorIconsRegular.sun,
                color: themeProvider.themeMode == ThemeMode.light ? const Color(AppColors.primaryDeeper) : null,
              ),
              title: const Text('Light Mode'),
              trailing: themeProvider.themeMode == ThemeMode.light
                  ? const Icon(PhosphorIconsRegular.check, color: Color(AppColors.primaryDeeper))
                  : null,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                PhosphorIconsRegular.moon,
                color: themeProvider.themeMode == ThemeMode.dark ? const Color(AppColors.primaryDeeper) : null,
              ),
              title: const Text('Dark Mode'),
              trailing: themeProvider.themeMode == ThemeMode.dark
                  ? const Icon(PhosphorIconsRegular.check, color: Color(AppColors.primaryDeeper))
                  : null,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
