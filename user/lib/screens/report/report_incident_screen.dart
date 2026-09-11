import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/providers/notification_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/incident.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/success_modal.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Custom types with descriptions and premium icons (no emojis)
  final _types = const [
    ('Insecurity', PhosphorIconsRegular.shieldWarning, 'Security threats, suspicious activities, or active hazards'),
    ('Theft', PhosphorIconsRegular.lockSimple, 'Stolen property, break-ins, or missing items'),
    ('Emergency', PhosphorIconsRegular.firstAid, 'Medical emergencies or critical safety assistance'),
    ('Power Outage', PhosphorIconsRegular.lightning, 'Power failures, sparking wires, or grid breakdowns'),
    ('Water Outage', PhosphorIconsRegular.drop, 'Dry pipes, broken water taps, or major flooding/leaks'),
    ('Fire Outbreak', PhosphorIconsRegular.fire, 'Active fires, smoke, or fire hazards'),
    ('Waste Dumps', PhosphorIconsRegular.trash, 'Hazardous waste accumulation or garbage pileup'),
    ('Other', PhosphorIconsRegular.dotsThreeCircle, 'Specify other custom incidents'),
  ];

  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _customTypeController = TextEditingController();
  int _step = 0;
  String _type = 'Insecurity';
  XFile? _image;
  bool _submitting = false;

  @override
  void dispose() {
    _desc.dispose();
    _location.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (file != null) {
        setState(() {
          _image = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get image: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _step = 1);
      return;
    }
    setState(() => _submitting = true);
    final firestore = context.read<FirestoreService>();
    final user = context.read<AuthService>().currentUser;
    final uid = user?.uid ?? 'guest';
    final reporterName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : (user?.email != null && user!.email!.contains('@')
            ? user.email!.split('@').first
            : 'BUK Student');

    try {
      String? url;
      if (_image != null) {
        url = await firestore.uploadImage(_image!, 'incident_images');
      }

      final newIncident = Incident(
        id: '',
        userId: uid,
        type: _type == 'Other' ? _customTypeController.text.trim() : _type,
        description: _desc.text.trim(),
        location: _location.text.trim(),
        imageUrl: url,
        createdAt: DateTime.now(),
        reporterName: reporterName,
        status: 'pending',
      );

      final docId = await firestore.createIncident(newIncident);

      if (mounted) {
        context.read<NotificationProvider>().addIncidentLocally(
          newIncident.copyWith(id: docId),
        );
      }

      if (!mounted) return;
      await showSuccessModal(
        context: context,
        title: 'Report Submitted',
        message: 'Your report has been submitted successfully. The smartBUK team will review it and take the necessary action.',
        buttonLabel: 'Done',
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Incident',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        leading: _step > 0
            ? IconButton(
                onPressed: () => setState(() => _step--),
                icon: const Icon(PhosphorIconsRegular.caretLeft),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildStepContent(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(0, 'Category', PhosphorIconsRegular.listBullets),
          _buildStepLine(0),
          _buildStepItem(1, 'Details', PhosphorIconsRegular.notePencil),
          _buildStepLine(1),
          _buildStepItem(2, 'Review', PhosphorIconsRegular.clipboardText),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, String label, IconData icon) {
    final isActive = _step == index;
    final isDone = _step > index;
    final primaryColor = const Color(AppColors.primaryDeeper);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive 
                ? primaryColor 
                : (isDone 
                    ? (isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF))
                    : Theme.of(context).cardColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isDone
                  ? primaryColor
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
              width: 1.5,
            ),
          ),
          child: Icon(
            isDone ? PhosphorIconsRegular.check : icon,
            size: 14,
            color: isActive ? Colors.white : (isDone ? primaryColor : const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? primaryColor : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterIndex) {
    final isDone = _step > afterIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 1.5,
        color: isDone 
            ? const Color(AppColors.primaryDeeper) 
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildStepCategory();
      case 1:
        return _buildStepDetails();
      case 2:
        return _buildStepReview();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepCategory() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      physics: const BouncingScrollPhysics(),
      key: const ValueKey('step_category'),
      children: [
        Text(
          'What are you reporting?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select the category that matches the active incident',
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 20),
        ..._types.map((t) {
          final isSelected = _type == t.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _type = t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF))
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(AppColors.primaryDeeper)
                        : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(AppColors.primaryDeeper).withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(AppColors.darkCardSubtle) : Colors.white)
                            : (isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF1F5F9)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        t.$2, 
                        size: 20, 
                        color: isSelected
                            ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper))
                            : (isDark ? const Color(AppColors.darkTextSecondary) : const Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.$1,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: isSelected 
                                  ? (isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper)) 
                                  : (isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.$3,
                            style: TextStyle(
                              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(AppColors.primaryDeeper) : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(AppColors.primaryDeeper)
                              : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFCBD5E1)),
                          width: 1.5,
                        ),
                      ),
                      child: isSelected 
                          ? const Icon(PhosphorIconsRegular.check, size: 12, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_type == 'Other') ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextFormField(
              controller: _customTypeController,
              validator: (v) {
                if (_type == 'Other' && (v == null || v.trim().isEmpty)) {
                  return 'Please specify the incident type';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Specify Incident Type *',
                hintText: 'e.g. Noise Complaint, Vandalism, Protest',
                prefixIcon: Icon(
                  PhosphorIconsRegular.note,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(AppColors.darkBorder)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(AppColors.primaryDeeper), width: 1.8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepDetails() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      physics: const BouncingScrollPhysics(),
      key: const ValueKey('step_details'),
      children: [
        Text(
          'Provide incident details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter descriptive elements and add any optional photo context',
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 20),
        
        // Description field
        TextFormField(
          controller: _desc,
          maxLines: 4,
          validator: (value) => Validators.requiredField(value, 'Description'),
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Describe what happened in detail...',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Icon(
                PhosphorIconsRegular.chatText,
                color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(AppColors.darkBorder)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(AppColors.primaryDeeper), width: 1.8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        
        // Location field
        TextFormField(
          controller: _location,
          validator: (value) => Validators.requiredField(value, 'Location'),
          decoration: InputDecoration(
            labelText: 'Location',
            hintText: 'Where did this happen?',
            prefixIcon: Icon(
              PhosphorIconsRegular.mapPin,
              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(AppColors.darkBorder)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(AppColors.primaryDeeper), width: 1.8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
        
        // Photo upload card
        Text(
          'Attach Photo (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 10),
        _image == null ? _buildPhotoUploadBoxes() : _buildPhotoPreviewBox(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoUploadBoxes() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(AppColors.darkCard) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.camera,
                    size: 28,
                    color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to Take Picture',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Opens your device camera to capture visual context',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: Icon(
              PhosphorIconsRegular.image,
              size: 16,
              color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
            ),
            label: Text(
              'Choose from Gallery',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPreviewBox() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0B1A2B),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb
                ? Image.network(_image!.path, fit: BoxFit.cover)
                : Image.file(
                    File(_image!.path),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(() => _image = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xBF000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsRegular.trash, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepReview() {
    final activeIcon = _types.firstWhere((t) => t.$1 == _type).$2;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      physics: const BouncingScrollPhysics(),
      key: const ValueKey('step_review'),
      children: [
        Text(
          'Review & Confirm',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Please verify your report details before submission',
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 20),
        
        Card(
          elevation: isDark ? 0 : 6,
          color: Theme.of(context).cardColor,
          shadowColor: const Color(0x1A0B1A2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? const Color(AppColors.darkBorder) : Colors.transparent,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _confirmRow(
                  label: 'Category',
                  value: _type == 'Other' ? _customTypeController.text.trim() : _type,
                  icon: activeIcon,
                  iconColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                ),
                Divider(
                  height: 24,
                  color: isDark
                      ? const Color(AppColors.darkBorder)
                      : const Color(0xFFEFF1F5),
                ),
                _confirmRow(
                  label: 'Location',
                  value: _location.text,
                  icon: PhosphorIconsRegular.mapPin,
                  iconColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                ),
                Divider(
                  height: 24,
                  color: isDark
                      ? const Color(AppColors.darkBorder)
                      : const Color(0xFFEFF1F5),
                ),
                _confirmRow(
                  label: 'Description',
                  value: _desc.text.isEmpty ? 'No description' : _desc.text,
                  icon: PhosphorIconsRegular.chatText,
                  iconColor: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primaryDeeper),
                ),
              ],
            ),
          ),
        ),
        if (_image != null) ...[
          const SizedBox(height: 20),
          Text(
            'ATTACHED PHOTO PREVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(AppColors.darkBorder)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F0B1A2B),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: kIsWeb
                  ? Image.network(_image!.path, fit: BoxFit.cover)
                  : Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _confirmRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting
            ? null
            : () {
                if (_step < 2) {
                  if (_step == 0 && _type == 'Other') {
                    if (_customTypeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please specify the incident type before continuing'),
                        ),
                      );
                      return;
                    }
                  }
                  if (_step == 1 && !_formKey.currentState!.validate()) return;
                  setState(() => _step++);
                } else {
                  _submit();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryDeeper),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          _submitting 
              ? 'Submitting...' 
              : (_step < 2 ? 'Continue' : 'Submit Report'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
