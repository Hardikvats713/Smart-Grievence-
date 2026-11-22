import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Result of a photo picking operation.
class PhotoPickResult {
  const PhotoPickResult({
    this.bytes,
    this.filePath,
    required this.fileName,
    this.errorMessage,
  });

  final Uint8List? bytes;
  final String? filePath;
  final String fileName;
  final String? errorMessage;

  bool get hasData => bytes != null || (filePath != null && filePath!.isNotEmpty);
}

/// Abstract contract for selecting or capturing a citizen avatar photo.
abstract class PhotoPickerService {
  Future<PhotoPickResult?> pickFromGallery();
  Future<PhotoPickResult?> captureWithCamera();
}

/// Default implementation for photo picking using image_picker with permission handling.
class DefaultPhotoPickerService implements PhotoPickerService {
  const DefaultPhotoPickerService();

  @override
  Future<PhotoPickResult?> pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      return PhotoPickResult(
        bytes: bytes,
        filePath: file.path,
        fileName: file.name,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PhotoPickerService] Error picking from gallery: $e');
      }
      return PhotoPickResult(
        fileName: '',
        errorMessage: 'Unable to access device gallery ($e). Please check storage/photos permission.',
      );
    }
  }

  @override
  Future<PhotoPickResult?> captureWithCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      return PhotoPickResult(
        bytes: bytes,
        filePath: file.path,
        fileName: file.name,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PhotoPickerService] Error capturing with camera: $e');
      }
      return PhotoPickResult(
        fileName: '',
        errorMessage: 'Unable to access camera ($e). Please check camera permission in device settings.',
      );
    }
  }
}

