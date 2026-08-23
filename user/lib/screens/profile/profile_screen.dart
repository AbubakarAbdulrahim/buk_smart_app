import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(AppColors.textPrimary),
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x060A1320), blurRadius: 16, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(photoUrl, fit: BoxFit.cover)
                              : const Icon(
                                  PhosphorIconsRegular.user,
                                  size: 36,
                                  color: Color(0xFF64748B),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 19.5,
                        color: Color(AppColors.textPrimary),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(AppColors.textSecondary),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Text(
                        '$department • $faculty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(AppColors.primaryDeeper),
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
                        foregroundColor: const Color(AppColors.textPrimary),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEFF1F4)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x020B1A2B), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildStatItem('Reports', '12')),
                    _buildStatDivider(),
                    Expanded(child: _buildStatItem('Lost Posts', '8')),
                    _buildStatDivider(),
                    Expanded(child: _buildStatItem('Resolved', '5')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Categories
              _buildSectionHeader('Account Settings'),
              const SizedBox(height: 8),
              _buildMenuList([
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
                const _MenuRow(
                  label: 'Notification Settings',
                  icon: PhosphorIconsRegular.bell,
                ),
                const _MenuRow(
                  label: 'Security & Access',
                  icon: PhosphorIconsRegular.lock,
                ),
              ]),
              const SizedBox(height: 20),

              _buildSectionHeader('Support & Policies'),
              const SizedBox(height: 8),
              _buildMenuList([
                const _MenuRow(
                  label: 'Help & Knowledge Base',
                  icon: PhosphorIconsRegular.question,
                ),
                const _MenuRow(
                  label: 'Submit Feedback',
                  icon: PhosphorIconsRegular.chatTeardrop,
                ),
                const _MenuRow(
                  label: 'About Campus App',
                  icon: PhosphorIconsRegular.info,
                ),
              ]),
              const SizedBox(height: 24),

              // Logout Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
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
                        children: const [
                          Icon(
                            PhosphorIconsRegular.signOut,
                            color: Color(AppColors.danger),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Log Out Account',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.danger),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(AppColors.textSecondary),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFEFF1F4),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(AppColors.textSecondary),
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF1F4)),
        boxShadow: const [
          BoxShadow(color: Color(0x020B1A2B), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 52);
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF334155),
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        PhosphorIconsRegular.caretRight,
        color: Color(0xFF94A3B8),
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
      await firestore.ensureUserProfile(
        uid: uid,
        email: email,
        name: _nameController.text.trim(),
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

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in.')));
    }

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
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(AppColors.textPrimary),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestore.userProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0x060A1320), blurRadius: 16, offset: Offset(0, 8)),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => _pickImage(initialPhotoUrl),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: _uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty
                                    ? Image.network(_uploadedPhotoUrl!, fit: BoxFit.cover)
                                    : (initialPhotoUrl.isNotEmpty
                                        ? Image.network(initialPhotoUrl, fit: BoxFit.cover)
                                        : const Icon(
                                            PhosphorIconsRegular.user,
                                            size: 40,
                                            color: Color(0xFF64748B),
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
                                color: const Color(AppColors.primaryDeeper),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
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

                  const Text(
                    'Personal Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Email Address (Unchangeable)',
                    controller: TextEditingController(text: user.email ?? 'abubakar.cs@buk.edu.ng'),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Matric / Registration Number',
                    controller: _matricController,
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Academic Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Faculty',
                    controller: _facultyController,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Department',
                    controller: _departmentController,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Program',
                    controller: _programController,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    label: 'Level (e.g. 400)',
                    controller: _levelController,
                  ),
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryDeeper),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(AppColors.textPrimary)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEFF1F4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(AppColors.primaryDeeper), width: 1.5),
            ),
            fillColor: enabled ? Colors.white : const Color(0xFFEFF1F4),
            filled: true,
          ),
          style: TextStyle(
            fontSize: 14,
            color: enabled ? const Color(AppColors.textPrimary) : const Color(AppColors.textSecondary),
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
          'My Lost & Found Posts',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(AppColors.textPrimary),
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
                  children: const [
                    Icon(PhosphorIconsRegular.pencilLine, size: 54, color: Color(0xFF94A3B8)),
                    SizedBox(height: 16),
                    Text(
                      'No Reports Posted',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(AppColors.textPrimary)),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'You have not published any lists yet. Tap "Report Item" on the home feed to begin reporting files.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(AppColors.textSecondary), height: 1.4),
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
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEFF1F4)),
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
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(PhosphorIconsRegular.image, size: 24, color: Color(AppColors.textSecondary)),
                            ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLost ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color: isLost ? const Color(0xFFB91C1C) : const Color(0xFF047857),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.location, style: const TextStyle(fontSize: 11.5, color: Color(AppColors.textSecondary))),
                          const SizedBox(height: 2),
                          Text(formattedDate, style: const TextStyle(fontSize: 10.5, color: Color(AppColors.textSecondary))),
                        ],
                      ),
                    ),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
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

