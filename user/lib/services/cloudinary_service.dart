import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/cloudinary_config.dart';

class ProgressMultipartRequest extends http.MultipartRequest {
  ProgressMultipartRequest(
    String method,
    Uri url, {
    required this.onProgress,
  }) : super(method, url);

  final void Function(double progress) onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final totalBytes = contentLength;
    int bytesSent = 0;

    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) {
        bytesSent += data.length;
        if (totalBytes > 0) {
          onProgress(bytesSent / totalBytes);
        }
        sink.add(data);
      },
    );

    return http.ByteStream(byteStream.transform(transformer));
  }
}

class CloudinaryService {
  final String _cloudName = CloudinaryConfig.cloudName;
  final String _uploadPreset = CloudinaryConfig.uploadPreset;
  final String _apiKey = CloudinaryConfig.apiKey;
  final String _apiSecret = CloudinaryConfig.apiSecret;
  final String _folder = CloudinaryConfig.folder;

  /// Uploads an image to Cloudinary.
  /// Reports upload progress via [onProgress] (0.0 to 1.0).
  /// Enforces progress reporting with [timeout] duration (defaults to 60s).
  Future<String?> uploadImage({
    required XFile file,
    void Function(double progress)? onProgress,
    Duration timeout = const Duration(seconds: 65),
  }) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception("File is empty.");
      }

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");
      
      final request = ProgressMultipartRequest(
        'POST',
        uri,
        onProgress: (p) {
          if (onProgress != null) {
            onProgress(p);
          }
        },
      );

      // Add file bytes
      final fileStream = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      );
      request.files.add(fileStream);

      // Add fields/parameters for unsigned upload configuration
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = _folder;

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['secure_url'] as String?;
      } else {
        final Map<String, dynamic> errData = jsonDecode(response.body);
        final errMsg = errData['error']?['message'] ?? 'Unknown Cloudinary error';
        throw Exception("Cloudinary upload failed (${response.statusCode}): $errMsg");
      }
    } on TimeoutException {
      throw Exception("Upload timed out. Please check your network connection.");
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an image from Cloudinary using a signed API request.
  /// Note: The public id must be extracted from the secure URL.
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final publicId = _extractPublicId(imageUrl);
      if (publicId == null) {
        throw Exception("Invalid Cloudinary URL - Could not parse public_id");
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Calculate signature: public_id=xxx&timestamp=yyy<api_secret>
      final signatureStr = "public_id=$publicId&timestamp=$timestamp$_apiSecret";
      final bytes = utf8.encode(signatureStr);
      final signature = sha1.convert(bytes).toString();

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/destroy");
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['result'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Helper to extract public ID from Cloudinary URL:
  /// e.g. https://res.cloudinary.com/cloudName/image/upload/v12345/folder/imageId.jpg
  /// Returns "folder/imageId"
  String? _extractPublicId(String url) {
    try {
      if (!url.contains("res.cloudinary.com")) return null;
      
      // Find the position of 'upload/' or similar action
      const lookups = ["/upload/", "/private/", "/authenticated/"];
      String? matchedLookup;
      for (final lookup in lookups) {
        if (url.contains(lookup)) {
          matchedLookup = lookup;
          break;
        }
      }
      
      if (matchedLookup == null) return null;
      
      final parts = url.split(matchedLookup);
      if (parts.length < 2) return null;
      
      // Strip out the version (e.g. v178201/ or without version)
      String pathAfterUpload = parts[1];
      if (pathAfterUpload.startsWith(RegExp('v[0-9]+/'))) {
        final slashIndex = pathAfterUpload.indexOf('/');
        pathAfterUpload = pathAfterUpload.substring(slashIndex + 1);
      }
      
      // Remove file extension
      final dotIndex = pathAfterUpload.lastIndexOf('.');
      if (dotIndex != -1) {
        pathAfterUpload = pathAfterUpload.substring(0, dotIndex);
      }
      
      return Uri.decodeFull(pathAfterUpload);
    } catch (_) {
      return null;
    }
  }
}
