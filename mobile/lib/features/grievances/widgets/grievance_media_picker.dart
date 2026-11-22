import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

/// Shows modal bottom sheet allowing the citizen to pick an image from gallery or camera.
Future<void> showGrievanceMediaPicker({
  required BuildContext context,
  required void Function(String fileName, Uint8List bytes) onMediaPicked,
  void Function(String error)? onError,
}) async {
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
                'Upload Evidence Photo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Attach photos of the issue to speed up grievance resolution',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.secondaryText,
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
                onTap: () async {
                  Navigator.of(bottomSheetContext).pop();
                  try {
                    final picker = ImagePicker();
                    final XFile? file = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1600,
                      maxHeight: 1600,
                      imageQuality: 85,
                    );
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      onMediaPicked(file.name, bytes);
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint('[GrievanceMediaPicker] Gallery pick error: $e');
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text('Could not access gallery: $e'),
                          action: SnackBarAction(
                            label: 'Retry',
                            textColor: AppColors.white,
                            onPressed: () => showGrievanceMediaPicker(
                              context: context,
                              onMediaPicked: onMediaPicked,
                              onError: onError,
                            ),
                          ),
                        ),
                      );
                    }
                    onError?.call(e.toString());
                  }
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
                onTap: () async {
                  Navigator.of(bottomSheetContext).pop();
                  try {
                    final picker = ImagePicker();
                    final XFile? file = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1600,
                      maxHeight: 1600,
                      imageQuality: 85,
                    );
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      onMediaPicked(file.name, bytes);
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint('[GrievanceMediaPicker] Camera capture error: $e');
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text('Could not access camera: $e'),
                          action: SnackBarAction(
                            label: 'Retry',
                            textColor: AppColors.white,
                            onPressed: () => showGrievanceMediaPicker(
                              context: context,
                              onMediaPicked: onMediaPicked,
                              onError: onError,
                            ),
                          ),
                        ),
                      );
                    }
                    onError?.call(e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Renders horizontal list of picked evidence photos with real image previews and remove badges.
class GrievanceMediaThumbnails extends StatelessWidget {
  const GrievanceMediaThumbnails({
    super.key,
    required this.attachments,
    required this.attachmentBytes,
    required this.onAddTap,
    required this.onRemoveTap,
  });

  final List<String> attachments;
  final List<dynamic> attachmentBytes;
  final VoidCallback onAddTap;
  final ValueChanged<int> onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Render each existing thumbnail
          ...attachments.asMap().entries.map((entry) {
            final idx = entry.key;
            final fileName = entry.value;
            final hasBytes = idx < attachmentBytes.length &&
                attachmentBytes[idx] is Uint8List &&
                (attachmentBytes[idx] as Uint8List).isNotEmpty;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasBytes
                        ? Image.memory(
                            attachmentBytes[idx] as Uint8List,
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_outlined,
                                color: AppColors.primary,
                                size: 26,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  fileName.split('/').last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 8,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                // Delete badge
                Positioned(
                  top: -4,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => onRemoveTap(idx),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 11,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

          // Plus / Add Photo Button
          InkWell(
            onTap: onAddTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Upload',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
