import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/incident.dart';
import '../../models/lost_found_item.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';
import '../common/async_state_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 38, backgroundColor: Color(0xFFE6EAEE), child: Icon(Icons.person, size: 38)),
          const SizedBox(height: 10),
          const Center(child: Text('Abubakar Muhammad', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20))),
          Center(child: Text(user?.email ?? 'abubakar.cs@buk.edu.ng', style: const TextStyle(color: Color(AppColors.textSecondary)))),
          const SizedBox(height: 4),
          const Center(child: Text('Computer Science\nFaculty of Computer Science', textAlign: TextAlign.center, style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12))),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _MetricCard(label: 'Reports', value: '12')),
              SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Lost Posts', value: '8')),
              SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Resolved', value: '5')),
            ],
          ),
          const SizedBox(height: 16),
          const AppSectionHeader(title: 'Account'),
          const SizedBox(height: 8),
          _Tile(label: 'My Reports', icon: Icons.description_outlined, onTap: user == null ? null : () => Navigator.pushNamed(context, AppRoutes.myReports, arguments: user.uid)),
          const SizedBox(height: 8),
          _Tile(label: 'My Lost & Found Posts', icon: Icons.search_rounded, onTap: user == null ? null : () => Navigator.pushNamed(context, AppRoutes.myLostFound, arguments: user.uid)),
          const SizedBox(height: 8),
          const _Tile(label: 'Settings', icon: Icons.settings_outlined),
          const SizedBox(height: 16),
          const AppSectionHeader(title: 'Support & Legal'),
          const SizedBox(height: 8),
          const _Tile(label: 'Help & Support', icon: Icons.help_outline),
          const SizedBox(height: 8),
          const _Tile(label: 'About Us', icon: Icons.info_outline),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(AppColors.danger),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async => auth.signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: ListTile(
        minVerticalPadding: 10,
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: AppIconBadge(icon: icon, bgColor: const Color(0x120085D0), iconColor: const Color(AppColors.primaryDeeper)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: StreamBuilder<List<Incident>>(
        stream: firestore.myIncidents(uid),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return AsyncStateView(
            connectionState: snapshot.connectionState,
            hasError: snapshot.hasError,
            errorMessage: snapshot.error?.toString(),
            isEmpty: items.isEmpty,
            emptyMessage: 'You have not submitted reports yet.',
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = items[index];
                return SectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.type, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(item.location),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MyLostFoundScreen extends StatelessWidget {
  const MyLostFoundScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Lost & Found')),
      body: StreamBuilder<List<LostFoundItem>>(
        stream: firestore.myLostFound(uid),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return AsyncStateView(
            connectionState: snapshot.connectionState,
            hasError: snapshot.hasError,
            errorMessage: snapshot.error?.toString(),
            isEmpty: items.isEmpty,
            emptyMessage: 'No posts yet.',
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = items[index];
                return SectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(item.location),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
