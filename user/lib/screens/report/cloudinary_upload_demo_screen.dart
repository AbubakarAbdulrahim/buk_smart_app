import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../services/cloudinary_service.dart';
import '../../services/image_picker_service.dart';

class CloudinaryUploadDemoScreen extends StatefulWidget {
  const CloudinaryUploadDemoScreen({super.key});

  @override
  State<CloudinaryUploadDemoScreen> createState() => _CloudinaryUploadDemoScreenState();
}

class _CloudinaryUploadDemoScreenState extends State<CloudinaryUploadDemoScreen> {
  final ImagePickerService _pickerService = ImagePickerService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  XFile? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedUrl;
  String? _error;
  bool _isSavingToFirestore = false;
  String? _savedDocId;

  // Retrieve test configuration or status
  @override
  void initState() {
    super.initState();
    _fetchLastUploadedImageUrl();
  }

  // Sample implementation showing how to fetch the URL later from Firestore
  Future<void> _fetchLastUploadedImageUrl() async {
    try {
      final querySnapshot = await _firestore
          .collection('cloudinary_demo')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          _uploadedUrl = data['imageUrl'] as String?;
          _savedDocId = querySnapshot.docs.first.id;
        });
      }
    } catch (_) {
      // Offline/missing collection setup fallback
    }
  }

  // Shows camera/gallery chooser Bottom Sheet with M3 design details
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.camera,
                      color: Color(AppColors.primaryDeeper),
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Capture a picture now'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(fromCamera: true);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.image,
                      color: Color(AppColors.textSecondary),
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Photo Library',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Choose from your gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(fromCamera: false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle capture/picking and implicit optimization/compression
  Future<void> _pickImage({required bool fromCamera}) async {
    setState(() {
      _error = null;
    });

    try {
      final XFile? image;
      if (fromCamera) {
        image = await _pickerService.captureFromCamera();
      } else {
        image = await _pickerService.pickFromGallery();
      }

      if (image != null) {
        setState(() {
          _imageFile = image;
          _uploadedUrl = null; // Clear previous upload when a new file is chosen
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  // Main compilation of picking + uploading + Firestore integration
  Future<void> _uploadAndSync() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
    });

    try {
      // 1. Upload to Cloudinary with Progress callbacks
      final secureUrl = await _cloudinaryService.uploadImage(
        file: _imageFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (secureUrl == null) {
        throw Exception("Unknown error uploading to Cloudinary - secure_url is null.");
      }

      // 2. Obtain secure_url and show state
      setState(() {
        _uploadedUrl = secureUrl;
        _isUploading = false;
        _isSavingToFirestore = true;
      });

      // 3. Save only the secure_url string to Firestore
      final docRef = await _firestore.collection('cloudinary_demo').add({
        'imageUrl': secureUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': 'demo_user_123',
      });

      setState(() {
        _isSavingToFirestore = false;
        _savedDocId = docRef.id;
        _imageFile = null; // Clear selection after complete success
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully uploaded and saved to Firestore!')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isUploading = false;
        _isSavingToFirestore = false;
      });
    }
  }

  // Demonstrate deleting from Cloudinary (both Cloudinary + Firestore cleanup)
  Future<void> _deleteUploadedImage() async {
    if (_uploadedUrl == null) return;

    final String oldUrl = _uploadedUrl!;

    setState(() {
      _isSavingToFirestore = true; // reutilize simple spinner
      _error = null;
    });

    try {
      // 1. Delete image from Cloudinary (using signed request helper)
      final deleted = await _cloudinaryService.deleteImage(oldUrl);
      if (!deleted) {
        throw Exception("Cloudinary rejected deletion. Check credentials and signature.");
      }

      // 2. Delete reference from Firestore list
      if (_savedDocId != null) {
        await _firestore.collection('cloudinary_demo').doc(_savedDocId).delete();
      }

      setState(() {
        _uploadedUrl = null;
        _savedDocId = null;
        _isSavingToFirestore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully from Cloudinary + Firestore!')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSavingToFirestore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cloudinary Upload',
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(AppColors.textPrimary)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload & Display images with Cloudinary + Firestore',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This screen demonstrates clean file integration: selection, size optimization, progress-monitored upload, and network caching.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              // Image Render Box (Local File or Network URL caching)
              Center(
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F0B1A2B),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: _imageFile != null
                        ? (kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                        : (_uploadedUrl != null && _uploadedUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: _uploadedUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(AppColors.primaryDeeper),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(
                                    PhosphorIconsRegular.warningOctagon,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.imageSquare,
                                      size: 48,
                                      color: Color(0x3B82F6AA),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No image selected',
                                      style: TextStyle(
                                        color: Color(AppColors.textSecondary),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upload progress indicator
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: const Color(0xFFEFF6FF),
                  color: const Color(AppColors.primaryDeeper),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uploading details... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.primaryDeeper),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // State feedback spinners
              if (_isSavingToFirestore) ...[
                const Center(
                  child: CircularProgressIndicator(color: Color(AppColors.primaryDeeper)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Syncing changes to Cloudinary & Firestore...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(AppColors.textSecondary)),
                ),
                const SizedBox(height: 20),
              ],

              // Error notification
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Control Actions Row
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading || _isSavingToFirestore
                        ? null
                        : _showImageSourceBottomSheet,
                    icon: const Icon(PhosphorIconsRegular.image),
                    label: Text(
                      _imageFile == null && _uploadedUrl == null
                          ? 'Select Image'
                          : 'Change Image',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(AppColors.textPrimary),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_imageFile != null)
                    ElevatedButton.icon(
                      onPressed: _isUploading || _isSavingToFirestore
                          ? null
                          : _uploadAndSync,
                      icon: const Icon(PhosphorIconsRegular.cloudArrowUp),
                      label: const Text('Upload & Save to Firestore'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryDeeper),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  if (_uploadedUrl != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isUploading || _isSavingToFirestore
                          ? null
                          : _deleteUploadedImage,
                      icon: const Icon(PhosphorIconsRegular.trash),
                      label: const Text('Delete from Production'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB91C1C),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
