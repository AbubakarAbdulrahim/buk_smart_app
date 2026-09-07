import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
    final firestore = context.read<FirestoreService>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: user == null ? const Stream.empty() : firestore.userProfile(user.uid),
        builder: (context, snapshot) {
          final profileData = snapshot.data?.data() ?? {};
          final name = profileData['name'] as String? ?? 'Abubakar Muhammad';
          final email = profileData['email'] as String? ?? (user?.email ?? 'abubakar.cs@buk.edu.ng');
          final department = profileData['department'] as String? ?? 'Computer Science';
          final faculty = profileData['faculty'] as String? ?? 'Faculty of Computing';
          final photoUrl = profileData['photoUrl'] as String?;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Profile Head Block
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Color(0x060A1320), blurRadius: 16, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(photoUrl, fit: BoxFit.cover)
                              : Icon(
                                  PhosphorIconsRegular.user,
                                  size: 36,
                                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF64748B),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 19.5,
                        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(AppColors.darkCardSubtle)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isDark
                              ? const Color(AppColors.darkBorder)
                              : const Color(0xFFDBEAFE),
                        ),
                      ),
                      child: Text(
                        '$department • $faculty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? const Color(AppColors.primaryLight)
                              : const Color(AppColors.primaryDeeper),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Edit Profile Pill Button
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                      icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 14),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? const Color(AppColors.darkTextPrimary)
                            : const Color(AppColors.textPrimary),
                        side: BorderSide(
                          color: isDark
                              ? const Color(AppColors.darkBorder)
                              : const Color(0xFFE2E8F0),
                        ),
                        minimumSize: const Size(120, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              user == null ? const SizedBox.shrink() : ProfileStatsCard(uid: user.uid),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Account Settings'),
              const SizedBox(height: 8),
              _buildMenuList(context, [
                _MenuRow(
                  label: 'My Reports',
                  icon: PhosphorIconsRegular.fileText,
                  onTap: user == null ? null : () => Navigator.pushNamed(context, AppRoutes.myReports, arguments: user.uid),
                ),
                _MenuRow(
                  label: 'My Lost & Found Posts',
                  icon: PhosphorIconsRegular.magnifyingGlass,
                  onTap: user == null ? null : () => Navigator.pushNamed(context, AppRoutes.myLostFound, arguments: user.uid),
                ),
                _MenuRow(
                  label: 'Settings',
                  icon: PhosphorIconsRegular.gear,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profileSettings),
                ),
              ]),
              const SizedBox(height: 20),

              _buildSectionHeader(context, 'Support & Policies'),
              const SizedBox(height: 8),
              _buildMenuList(context, [
                const _MenuRow(
                  label: 'Help & Knowledge Base',
                  icon: PhosphorIconsRegular.question,
                ),
                const _MenuRow(
                  label: 'Submit Feedback',
                  icon: PhosphorIconsRegular.chatTeardrop,
                ),
              ]),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5),
                    width: 1.2,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFFB91C1C).withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async => auth.signOut(),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsRegular.signOut,
                            color: isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out Account',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isDark
                ? const Color(AppColors.darkTextSecondary)
                : const Color(AppColors.textSecondary),
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
                BoxShadow(color: Color(0x020B1A2B), blurRadius: 10, offset: Offset(0, 4)),
              ],
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              color: isDark
                  ? const Color(AppColors.darkBorder)
                  : const Color(0xFFF1F5F9),
              indent: 52,
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _matricController;
  late TextEditingController _facultyController;
  late TextEditingController _departmentController;
  late TextEditingController _programController;
  late TextEditingController _levelController;
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _matricController = TextEditingController();
    _facultyController = TextEditingController();
    _departmentController = TextEditingController();
    _programController = TextEditingController();
    _levelController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matricController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    _programController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String initialPhotoUrl) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(PhosphorIconsRegular.camera),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.image),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final firestore = context.read<FirestoreService>();
      final url = await firestore.uploadImage(pickedFile, 'profile_pictures');
      if (url != null) {
        setState(() {
          _uploadedPhotoUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture uploaded!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile(String uid, String email) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final firestore = context.read<FirestoreService>();
      final updatedName = _nameController.text.trim();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.updateDisplayName(updatedName);
          if (_uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty) {
            await user.updatePhotoURL(_uploadedPhotoUrl);
          }
        } catch (_) {}
      }

      await firestore.ensureUserProfile(
        uid: uid,
        email: email,
        name: updatedName,
        matricNumber: _matricController.text.trim(),
        faculty: _facultyController.text.trim(),
        department: _departmentController.text.trim(),
        program: _programController.text.trim(),
        level: _levelController.text.trim(),
        photoUrl: _uploadedPhotoUrl,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in.')));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(AppColors.darkBackground) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.userProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
              ),
            );
          }

          String initialPhotoUrl = '';
          if (!_isInitialized && snapshot.hasData) {
            final data = snapshot.data?.data() ?? {};
            _nameController.text = data['name'] as String? ?? 'Abubakar Muhammad';
            _matricController.text = data['matricNumber'] as String? ?? '';
            _facultyController.text = data['faculty'] as String? ?? 'Faculty of Computing';
            _departmentController.text = data['department'] as String? ?? 'Computer Science';
            _programController.text = data['program'] as String? ?? '';
            _levelController.text = data['level'] as String? ?? '';
            _uploadedPhotoUrl = data['photoUrl'] as String?;
            _isInitialized = true;
          }

          if (snapshot.hasData) {
            final data = snapshot.data?.data() ?? {};
            initialPhotoUrl = data['photoUrl'] as String? ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Picture Editor Bubble
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(AppColors.darkCard) : Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            boxShadow: isDark
                                ? []
                                : const [
                                    BoxShadow(color: Color(0x060A1320), blurRadius: 16, offset: Offset(0, 8)),
                                  ],
                          ),
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => _pickImage(initialPhotoUrl),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: _uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty
                                    ? Image.network(_uploadedPhotoUrl!, fit: BoxFit.cover)
                                    : (initialPhotoUrl.isNotEmpty
                                        ? Image.network(initialPhotoUrl, fit: BoxFit.cover)
                                        : Icon(
                                            PhosphorIconsRegular.user,
                                            size: 40,
                                            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF64748B),
                                          )),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => _pickImage(initialPhotoUrl),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(AppColors.darkBackground) : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                PhosphorIconsRegular.camera,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    isDark: isDark,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Email Address (Unchangeable)',
                    controller: TextEditingController(text: user.email ?? 'abubakar.cs@buk.edu.ng'),
                    isDark: isDark,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Matric / Registration Number',
                    controller: _matricController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Academic Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Faculty',
                    controller: _facultyController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Department',
                    controller: _departmentController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Program',
                    controller: _programController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Level (e.g. 400)',
                    controller: _levelController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : () => _saveProfile(user.uid, user.email ?? ''),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          cursorColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                width: 1.5,
              ),
            ),
            fillColor: enabled
                ? (isDark ? const Color(AppColors.darkCardSubtle) : Colors.white)
                : (isDark ? const Color(AppColors.darkCard) : const Color(0xFFEFF1F4)),
            filled: true,
          ),
          style: TextStyle(
            fontSize: 14,
            color: enabled
                ? (isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary))
                : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary)),
          ),
        ),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Lost & Found Posts',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<LostFoundItem>>(
        stream: firestore.myLostFound(uid),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return AsyncStateView(
            connectionState: snapshot.connectionState,
            hasError: snapshot.hasError,
            errorMessage: snapshot.error?.toString(),
            isEmpty: items.isEmpty,
            emptyWidget: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsRegular.pencilLine, size: 54, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 16),
                    Text(
                      'No Reports Posted',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You have not published any lists yet. Tap "Report Item" on the home feed to begin reporting files.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isLost = item.type == 'lost';
                final formattedDate = DateFormat('MMM dd, h:mm a').format(item.createdAt);

                return Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(item.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                          : Container(
                              width: 56,
                              height: 56,
                              color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9),
                              child: Icon(
                                PhosphorIconsRegular.image,
                                size: 24,
                                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              ),
                            ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLost
                                ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color: isLost
                                  ? (isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C))
                                  : (isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF047857)),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 16,
                      color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.lostFoundDetail,
                        arguments: item.id,
                      );
                    },
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

class ProfileStatsCard extends StatefulWidget {
  final String uid;

  const ProfileStatsCard({super.key, required this.uid});

  @override
  State<ProfileStatsCard> createState() => _ProfileStatsCardState();
}

class _ProfileStatsCardState extends State<ProfileStatsCard> {
  int _reportsCount = 0;
  int _lostPostsCount = 0;
  int _resolvedCount = 0;

  StreamSubscription? _incidentsSub;
  StreamSubscription? _lostFoundSub;

  @override
  void initState() {
    super.initState();
    final firestore = context.read<FirestoreService>();
    _incidentsSub = firestore.myIncidents(widget.uid).listen((incidents) {
      if (mounted) {
        setState(() {
          _reportsCount = incidents.length;
        });
      }
    });
    _lostFoundSub = firestore.myLostFound(widget.uid).listen((items) {
      if (mounted) {
        setState(() {
          _lostPostsCount = items.length;
          _resolvedCount = items.where((item) => item.isResolved).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _incidentsSub?.cancel();
    _lostFoundSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(AppColors.darkBorder)
              : const Color(0xFFEFF1F4),
        ),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(color: Color(0x020B1A2B), blurRadius: 10, offset: Offset(0, 4)),
              ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Reports', '$_reportsCount', isDark)),
          _buildStatDivider(isDark),
          Expanded(child: _buildStatItem('Lost Posts', '$_lostPostsCount', isDark)),
          _buildStatDivider(isDark),
          Expanded(child: _buildStatItem('Resolved', '$_resolvedCount', isDark)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 28,
      color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
    );
  }
}
