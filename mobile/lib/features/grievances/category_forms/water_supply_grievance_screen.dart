import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_media_picker.dart';
import '../widgets/grievance_step_progress_indicator.dart';

/// Screen 20 — Water Supply Grievance Form.
class WaterSupplyGrievanceScreen extends StatefulWidget {
  const WaterSupplyGrievanceScreen({
    super.key,
    this.controller,
  });

  final GrievanceController? controller;

  @override
  State<WaterSupplyGrievanceScreen> createState() => _WaterSupplyGrievanceScreenState();
}

class _WaterSupplyGrievanceScreenState extends State<WaterSupplyGrievanceScreen> {
  late final GrievanceController _controller;
  final _formKey = GlobalKey<FormState>();

  String? _selectedIssueType;
  String? _selectedDuration;
  final _connectionNumController = TextEditingController();
  final _descController = TextEditingController();

  final List<String> _issueTypes = [
    'No water supply',
    'Low water pressure',
    'Pipeline leakage',
    'Dirty or contaminated water',
    'Broken water connection',
    'Irregular water supply',
    'Other water issue',
  ];

  final List<String> _durations = [
    'Less than one day',
    '1–3 days',
    '4–7 days',
    'More than one week',
    'Not sure',
  ];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
    _descController.text = _controller.draft.description;
  }

  @override
  void dispose() {
    _connectionNumController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      final conn = _connectionNumController.text.trim();
      String extraInfo = '';
      if (conn.isNotEmpty) extraInfo += ' [Water Conn No: $conn]';
      if (_selectedDuration != null) extraInfo += ' [Duration: $_selectedDuration]';

      _controller.updateDetails(
        title: _selectedIssueType ?? 'Water Supply Issue',
        description: '${_descController.text.trim()}$extraInfo',
      );
      Navigator.of(context).pushNamed('/submit-grievance/location');
    }
  }

  void _openMediaPicker() {
    showGrievanceMediaPicker(
      context: context,
      onMediaPicked: (name, bytes) {
        _controller.addAttachment(name, bytes: bytes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final draft = _controller.draft;

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
                        title: 'Water Supply Grievance',
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      const GrievanceStepProgressIndicator(currentStep: 2),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Issue Type *
                          const Text(
                            'Issue Type *',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedIssueType,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              hintText: 'Select water supply issue',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            items: _issueTypes
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedIssueType = val),
                            validator: (val) =>
                                val == null ? 'Please select an issue type' : null,
                          ),
                          const SizedBox(height: 14),

                          // 2. Water Connection Number (Optional)
                          const Text(
                            'Water Connection Number (Optional)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _connectionNumController,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              hintText: 'e.g. WTR-88219',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 3. Duration of Problem *
                          const Text(
                            'Duration of Problem *',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDuration,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              hintText: 'Select problem duration',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            items: _durations
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedDuration = val),
                            validator: (val) =>
                                val == null ? 'Please select problem duration' : null,
                          ),
                          const SizedBox(height: 14),

                          // 4. Description *
                          const Text(
                            'Description *',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _descController,
                            maxLines: 4,
                            maxLength: 500,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              hintText: 'Describe the water supply issue...',
                              counterText: '${_descController.text.length}/500',
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please describe the water supply issue';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // 5. Evidence
                          const Text(
                            'Upload Photos / Videos',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),

                          GrievanceMediaThumbnails(
                            attachments: draft.attachments,
                            attachmentBytes: draft.attachmentBytes,
                            onAddTap: _openMediaPicker,
                            onRemoveTap: (idx) => _controller.removeAttachment(idx),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Next Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
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
