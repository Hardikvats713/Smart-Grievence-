import 'package:flutter/foundation.dart';

/// Result of a photo picking operation.
class PhotoPickResult {
  const PhotoPickResult({
    this.bytes,
    this.filePath,
    required this.fileName,
  });

  final Uint8List? bytes;
  final String? filePath;
  final String fileName;

  bool get hasData => bytes != null || (filePath != null && filePath!.isNotEmpty);
}

/// Abstract contract for selecting or capturing a citizen avatar photo.
abstract class PhotoPickerService {
  Future<PhotoPickResult?> pickFromGallery();
  Future<PhotoPickResult?> captureWithCamera();
}

/// Default implementation for photo picking.
///
/// Uses standard platform hooks or documents camera/gallery package requirement.
class DefaultPhotoPickerService implements PhotoPickerService {
  const DefaultPhotoPickerService();

  @override
  Future<PhotoPickResult?> pickFromGallery() async {
    if (kDebugMode) {
      debugPrint('[PhotoPickerService] Gallery picker requested.');
    }
    // Pure Flutter SDK stub: returns null or handles permission.
    // Integrate image_picker or native file selector in production.
    return null;
  }

  @override
  Future<PhotoPickResult?> captureWithCamera() async {
    if (kDebugMode) {
      debugPrint('[PhotoPickerService] Camera capture requested.');
    }
    return null;
  }
}

