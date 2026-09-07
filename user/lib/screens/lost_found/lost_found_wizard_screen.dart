import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/lost_found_item.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';

class LostFoundWizardScreen extends StatefulWidget {
  const LostFoundWizardScreen({super.key});

  @override
  State<LostFoundWizardScreen> createState() => _LostFoundWizardScreenState();
}

class _LostFoundWizardScreenState extends State<LostFoundWizardScreen> {
  int _currentStep = 0;
  bool _isPublishing = false;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Type Selection
  String _type = 'lost'; // 'lost' or 'found'

  // Step 2: Images Collection
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Step 3: Item Info
  final TextEditingController _nameController = TextEditingController();
  String _category = 'Others';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();

  // Step 4: Location details
  String _faculty = 'Others';
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _hallController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _customLocationController = TextEditingController();

  // Step 5: Date & Time Picker
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Step 6: Contact details
  String _contactPreference = 'Show Name'; // 'Anonymous', 'Show Name', 'Phone', 'Email'
  final TextEditingController _contactValueController = TextEditingController();

  final List<String> _categories = const [
    'Student ID',
    'Bags',
    'Phones',
    'Laptop',
    'Documents',
    'Keys',
    'Wallet',
    'Clothing',
    'Books',
    'Accessories',
    'Others',
  ];

  final List<String> _faculties = const [
    'Agriculture',
    'Arts and Islamic Studies',
    'Basic Medical Sciences',
    'Clinical Sciences',
    'Communication',
    'Computer Science',
    'Earth and Environmental Sciences',
    'Education',
    'Engineering',
    'Law',
    'Life Sciences',
    'Management Sciences',
    'Pharmaceutical Sciences',
    'Physical Sciences',
    'Social Sciences',
    'Veterinary Medicine',
    'Others',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _brandController.dispose();
    _featuresController.dispose();
    _buildingController.dispose();
    _hallController.dispose();
    _departmentController.dispose();
    _customLocationController.dispose();
    _contactValueController.dispose();
    super.dispose();
  }

  // Handle camera/gallery photo pick
  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 5 images.')),
      );
      return;
    }
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (file != null) {
        setState(() {
          _selectedImages.add(file);
        });
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  // Select Date picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Select Time picker
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Publish report end-to-end
  Future<void> _publishReport() async {
    setState(() => _isPublishing = true);

    try {
      final service = context.read<FirestoreService>();
      final auth = context.read<AuthService>();
      final currentUser = auth.currentUser;

      // 1. Cloudinary upload pipeline for multiple photos
      final List<String> imageUrlsList = [];
      String? primaryUrl;

      for (var f in _selectedImages) {
        final url = await service.uploadImage(f, 'lost_found_uploads');
        if (url != null) {
          imageUrlsList.add(url);
        }
      }

      if (imageUrlsList.isNotEmpty) {
        primaryUrl = imageUrlsList.first;
      }

      // Format location detail
      final compositeLocation = _customLocationController.text.isNotEmpty
          ? '${_customLocationController.text.trim()} (${_faculty} Faculty)'
          : '${_faculty} Faculty, ${_buildingController.text.trim()}';

      // Pick contact details
      final resolvedContactValue = _contactPreference == 'Anonymous'
          ? 'Anonymous'
          : _contactValueController.text.trim().isNotEmpty
              ? _contactValueController.text.trim()
              : currentUser?.email ?? 'Unknown';

      // Combine step date and timeOfDay
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create model instances
      final item = LostFoundItem(
        id: '',
        userId: currentUser?.uid ?? 'guest',
        category: _category,
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: compositeLocation,
        contact: resolvedContactValue,
        type: _type,
        createdAt: combinedDateTime,
        imageUrl: primaryUrl,
        imageUrls: imageUrlsList,
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
        brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
        uniqueFeatures: _featuresController.text.trim().isNotEmpty ? _featuresController.text.trim() : null,
        contactType: _contactPreference,
        isVerified: currentUser?.email?.endsWith('.edu.ng') ?? false,
      );

      await service.createLostFound(item);

      if (!mounted) return;
      
      // Success Dialog Representation (Deliverable #10)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Report Published! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Your Lost & Found listing statement has been safely registered. Thank you for reporting!',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Exit Wizard screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text(
              'Publish Failed ⚠️',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'We encountered an issue during upload: ${e.toString()}',
              style: const TextStyle(height: 1.3),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  // Linear progression handler
  void _nextStep() {
    if (_currentStep == 2) {
      // Validate form
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      _publishReport();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / 6.0;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.x),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Report an Item',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(AppColors.primary)),
                minHeight: 3,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress subtitle
                        Text(
                          'STEP ${_currentStep + 1} OF 6',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primary),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStepBody(),
                      ],
                    ),
                  ),
                ),

                // Control Buttons bar at footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF1F4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEFF1F4),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _currentStep == 5 ? 'Publish Report' : 'Continue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Blur overlay while uploading/publishing (Deliverable #9)
        if (_isPublishing)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
              child: Center(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.primary)),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Uploading files to cloud...',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'This may take a brief moment',
                          style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Switch structure displaying corresponding layouts
  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return _buildStep1TypeSelection();
      case 1:
        return _buildStep2ImageUpload();
      case 2:
        return _buildStep3ItemDetails();
      case 3:
        return _buildStep4Location();
      case 4:
        return _buildStep5DateTime();
      case 5:
        return _buildStep6Contact();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Is this a Lost or Found item
  Widget _buildStep1TypeSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happened?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Specify if this is your missing item, or an item you discovered on campus.',
          style: TextStyle(
            color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _type = 'lost'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: _type == 'lost'
                  ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                  : (isDark ? const Color(AppColors.darkCard) : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _type == 'lost'
                    ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
                    : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4)),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.info,
                    color: isDark ? const Color(AppColors.darkDanger) : const Color(0xFFB91C1C),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lost Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'I have lost an item and want to ask the community for assistance.',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'lost',
                  groupValue: _type,
                  activeColor: isDark ? const Color(AppColors.darkDanger) : const Color(0xFFEF4444),
                  onChanged: (val) {
                    if (val != null) setState(() => _type = val);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => _type = 'found'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: _type == 'found'
                  ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                  : (isDark ? const Color(AppColors.darkCard) : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _type == 'found'
                    ? (isDark ? const Color(0xFF047857) : const Color(0xFF6EE7B7))
                    : (isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4)),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.handWaving,
                    color: isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF047857),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Found Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'I have found a lost item and wish to surrender or locate the owner.',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'found',
                  groupValue: _type,
                  activeColor: isDark ? const Color(AppColors.darkSuccess) : const Color(0xFF10B981),
                  onChanged: (val) {
                    if (val != null) setState(() => _type = val);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Upload Pictures
  Widget _buildStep2ImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Photos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(AppColors.textPrimary)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Adding crisp photographs of the item improves recognition speed up to 3x. Add up to 5 photos.',
          style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 24),

        // Preview Grid
        if (_selectedImages.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, idx) {
              final img = _selectedImages[idx];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(img.path, fit: BoxFit.cover, height: double.infinity, width: double.infinity)
                        : Image.file(File(img.path), fit: BoxFit.cover, height: double.infinity, width: double.infinity),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(idx);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(PhosphorIconsRegular.trash, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],

        // Input selectors
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(PhosphorIconsRegular.camera, color: Color(AppColors.primary)),
                label: const Text('Camera', style: TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(AppColors.primary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(PhosphorIconsRegular.image, color: Color(AppColors.primary)),
                label: const Text('Gallery', style: TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(AppColors.primary)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Item Metadata details form
  Widget _buildStep3ItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Specifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(AppColors.textPrimary)),
        ),
        const SizedBox(height: 24),

        // Item Name
        TextFormField(
          controller: _nameController,
          validator: (v) => Validators.requiredField(v, 'Item Name'),
          decoration: InputDecoration(
            labelText: 'Item Name *',
            hintText: 'e.g. Student ID Card, iPhone 13 Pro',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),

        // Category dropdown
        DropdownButtonFormField<String>(
          value: _category,
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _category = val);
          },
          decoration: InputDecoration(
            labelText: 'Category *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          validator: (v) => Validators.requiredField(v, 'Description'),
          decoration: InputDecoration(
            labelText: 'Detailed Description *',
            hintText: 'Describe key identify markings, status, condition...",',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),

        // Color & Brand row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g. Matte Black',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand',
                  hintText: 'e.g. Apple',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Unique features
        TextFormField(
          controller: _featuresController,
          decoration: InputDecoration(
            labelText: 'Unique Markings/Serial Number',
            hintText: 'e.g. Cracked top lens, name sticker on back',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // Step 4: Faculty / Coordinates Details
  Widget _buildStep4Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(AppColors.textPrimary)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Specify where the item was lost or found on campus to assist searches.',
          style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 24),

        // Faculty Selection
        DropdownButtonFormField<String>(
          value: _faculty,
          items: _faculties
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _faculty = val);
          },
          decoration: InputDecoration(
            labelText: 'Faculty *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Building / Hall / Department Info row
        TextFormField(
          controller: _buildingController,
          decoration: InputDecoration(
            labelText: 'Building Complex / Lecture Theatre',
            hintText: 'e.g. CITS Hall, Old Site LT1',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _hallController,
                decoration: InputDecoration(
                  labelText: 'Room/Classroom No.',
                  hintText: 'e.g. Lab 4B',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  hintText: 'e.g. Software Eng.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Custom details
        TextFormField(
          controller: _customLocationController,
          decoration: InputDecoration(
            labelText: 'Custom Location Instructions',
            hintText: 'e.g. Under the bench outside department library',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // Step 5: Picker for Dates & Times
  Widget _buildStep5DateTime() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateString = DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate);
    final timeString = _selectedTime.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 24),

        // Picker triggers layout
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.calendarBlank,
                  color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Occurred',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(AppColors.darkCardSubtle) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(AppColors.darkBorder) : const Color(0xFFEFF1F4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.clock,
                  color: isDark ? const Color(AppColors.primaryLight) : const Color(AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Approximate Time',
                        style: TextStyle(
                          color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? const Color(AppColors.darkTextPrimary) : const Color(AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  color: isDark ? const Color(AppColors.darkTextSecondary) : const Color(AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 6: Contact specifications
  Widget _buildStep6Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(AppColors.textPrimary)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Control how students reach out to claim or discuss this listing.',
          style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 24),

        // Preferences dropDown
        DropdownButtonFormField<String>(
          value: _contactPreference,
          items: const [
            DropdownMenuItem(value: 'Anonymous', child: Text('Anonymous (Students must request details)')),
            DropdownMenuItem(value: 'Show Name', child: Text('Show Account Name')),
            DropdownMenuItem(value: 'Phone', child: Text('Provide Phone Number')),
            DropdownMenuItem(value: 'Email', child: Text('Provide Custom Email')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _contactPreference = val;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Preference *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        if (_contactPreference == 'Phone' || _contactPreference == 'Email')
          TextFormField(
            controller: _contactValueController,
            validator: (v) => Validators.requiredField(v, 'Contact Details'),
            decoration: InputDecoration(
              labelText: _contactPreference == 'Phone' ? 'Phone Number *' : 'Email Address *',
              hintText: _contactPreference == 'Phone' ? 'e.g. +234...' : 'e.g. user@gmail.com',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: _contactPreference == 'Phone' ? TextInputType.phone : TextInputType.emailAddress,
          ),
      ],
    );
  }
}
