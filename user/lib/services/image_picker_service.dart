import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Captures a photo using the phone's native camera.
  /// Compresses the image and scales it down to maximum parameters.
  Future<XFile?> captureFromCamera({
    double maxWidth = 1200,
    double maxHeight = 1200,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return file;
    } catch (e) {
      throw Exception("Unable to capture image from camera: $e");
    }
  }

  /// Selects a photo from the phone's photo library.
  /// Compresses the image and scales it down to maximum parameters.
  Future<XFile?> pickFromGallery({
    double maxWidth = 1200,
    double maxHeight = 1200,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return file;
    } catch (e) {
      throw Exception("Unable to pick image from gallery: $e");
    }
  }
}
