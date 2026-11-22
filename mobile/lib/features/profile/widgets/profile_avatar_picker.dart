import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/photo_picker_service.dart';

/// Circular profile avatar with camera action button and photo sheet.
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    this.photoBytes,
    this.photoPath,
    required this.onPhotoSelected,
    this.pickerService = const DefaultPhotoPickerService(),
  });

  final Uint8List? photoBytes;
  final String? photoPath;
  final ValueChanged<PhotoPickResult?> onPhotoSelected;
  final PhotoPickerService pickerService;

  bool get _hasPhoto => photoBytes != null || (photoPath != null && photoPath!.isNotEmpty);

  Future<void> _pickFromGallery(BuildContext outerContext) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProfileAvatarPicker] Gallery picker invoked');
      }
      final result = await pickerService.pickFromGallery();
      if (kDebugMode) {
        debugPrint('[ProfileAvatarPicker] Gallery result: hasData=${result?.hasData}, '
            'bytes=${result?.bytes?.length}, path=${result?.filePath}, error=${result?.errorMessage}');
      }
      if (result != null && result.hasData) {
        onPhotoSelected(result);
      } else if (result?.errorMessage != null) {
        if (outerContext.mounted) {
          ScaffoldMessenger.of(outerContext).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(result!.errorMessage!),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProfileAvatarPicker] Gallery exception: $e');
      }
      if (outerContext.mounted) {
        ScaffoldMessenger.of(outerContext).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Could not open gallery: $e'),
          ),
        );
      }
    }
  }

  Future<void> _captureWithCamera(BuildContext outerContext) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProfileAvatarPicker] Camera capture invoked');
      }
      final result = await pickerService.captureWithCamera();
      if (kDebugMode) {
        debugPrint('[ProfileAvatarPicker] Camera result: hasData=${result?.hasData}, '
            'bytes=${result?.bytes?.length}, path=${result?.filePath}, error=${result?.errorMessage}');
      }
      if (result != null && result.hasData) {
        onPhotoSelected(result);
      } else if (result?.errorMessage != null) {
        if (outerContext.mounted) {
          ScaffoldMessenger.of(outerContext).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(result!.errorMessage!),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProfileAvatarPicker] Camera exception: $e');
      }
      if (outerContext.mounted) {
        ScaffoldMessenger.of(outerContext).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Could not open camera: $e'),
          ),
        );
      }
    }
  }

  void _showPickerOptions(BuildContext context) {
    // Capture the outer scaffold context before opening the bottom sheet
    final outerContext = context;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    // Close the bottom sheet first, then open the picker
                    Navigator.of(bottomSheetContext).pop();
                    // Use a slight delay to ensure the sheet is fully dismissed
                    // before the file picker dialog opens (critical on Web)
                    Future.delayed(const Duration(milliseconds: 150), () {
                      // ignore: use_build_context_synchronously
                      _pickFromGallery(outerContext);
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Future.delayed(const Duration(milliseconds: 150), () {
                      // ignore: use_build_context_synchronously
                      _captureWithCamera(outerContext);
                    });
                  },
                ),
                if (_hasPhoto) ...[
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      onPhotoSelected(null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showPickerOptions(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Circular Avatar Surface
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondarySurface,
                border: Border.all(
                  color: AppColors.white,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryText.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: photoBytes != null
                    ? Image.memory(
                        photoBytes!,
                        fit: BoxFit.cover,
                        width: 78,
                        height: 78,
                      )
                    : const Icon(
                        Icons.person_outline_rounded,
                        size: 38,
                        color: AppColors.primary,
                      ),
              ),
            ),

            // Camera Action Pill Button Overlapping Bottom-Right
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
