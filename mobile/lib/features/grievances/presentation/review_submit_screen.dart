import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_step_progress_indicator.dart';

/// Screen 11 — Review & Submit.
class ReviewSubmitScreen extends StatefulWidget {
  const ReviewSubmitScreen({
    super.key,
    this.controller,
  });

  final GrievanceController? controller;

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  late final GrievanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
  }

  Future<void> _onSubmit() async {
    final result = await _controller.submit();
    if (result != null && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/submit-grievance/confirmation',
        (route) => route.settings.name == '/home',
      );
    } else if (mounted && _controller.submissionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(_controller.submissionError!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final draft = _controller.draft;
        final isSubmitting = _controller.isSubmitting;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      GrievanceHeader(
                        title: 'Review & Submit',
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      const GrievanceStepProgressIndicator(currentStep: 4),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Category Row
                        _ReviewCardItem(
                          icon: draft.category?.icon ?? Icons.category_outlined,
                          title: 'Category',
                          content: draft.category?.displayName ?? 'Not selected',
                          onEdit: () => Navigator.of(context).popUntil(
                            (r) => r.settings.name == '/submit-grievance',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title Row
                        _ReviewCardItem(
                          icon: Icons.title_rounded,
                          title: 'Title',
                          content: draft.title.isNotEmpty ? draft.title : 'No title provided',
                          onEdit: () => Navigator.of(context).popUntil(
                            (r) => r.settings.name == '/submit-grievance/details',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description Row
                        _ReviewCardItem(
                          icon: Icons.description_outlined,
                          title: 'Description',
                          content: draft.description.isNotEmpty
                              ? draft.description
                              : 'No description provided',
                          onEdit: () => Navigator.of(context).popUntil(
                            (r) => r.settings.name == '/submit-grievance/details',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Location Row
                        _ReviewCardItem(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          content: draft.locationAddress,
                          onEdit: () => Navigator.of(context).popUntil(
                            (r) => r.settings.name == '/submit-grievance/location',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Attachments Row
                        _ReviewCardItem(
                          icon: Icons.attach_file_rounded,
                          title: 'Attachments',
                          content: '${draft.attachments.length} photo${draft.attachments.length == 1 ? '' : 's'}',
                          onEdit: () => Navigator.of(context).popUntil(
                            (r) => r.settings.name == '/submit-grievance/details',
                          ),
                        ),
                        if (draft.attachments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: draft.attachments.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final hasBytes = i < draft.attachmentBytes.length &&
                                    draft.attachmentBytes[i] is Uint8List &&
                                    (draft.attachmentBytes[i] as Uint8List).isNotEmpty;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: AppColors.secondarySurface,
                                    child: hasBytes
                                        ? Image.memory(
                                            draft.attachmentBytes[i] as Uint8List,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.image_outlined,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Submit Grievance',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewCardItem extends StatelessWidget {
  const _ReviewCardItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final String content;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.secondaryText,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
