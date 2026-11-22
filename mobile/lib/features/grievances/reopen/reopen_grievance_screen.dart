import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../widgets/grievance_header.dart';

/// Screen 25 — Reopen Grievance.
class ReopenGrievanceScreen extends StatefulWidget {
  const ReopenGrievanceScreen({
    super.key,
    this.grievanceReference = 'SG2503170005',
    this.grievanceId = 'g-2',
    this.controller,
  });

  final String grievanceReference;
  final String grievanceId;
  final GrievanceController? controller;

  @override
  State<ReopenGrievanceScreen> createState() => _ReopenGrievanceScreenState();
}

class _ReopenGrievanceScreenState extends State<ReopenGrievanceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  final _detailsController = TextEditingController();
  final List<String> _evidenceList = [];
  bool _isSubmitting = false;

  final List<String> _reopenReasons = [
    'Issue is not fully resolved.',
    'The issue has occurred again.',
    'Resolution provided was insufficient.',
    'Other.',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _addEvidence() {
    setState(() {
      _evidenceList.add('reopen_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });
  }

  Future<void> _submitReopenRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for reopening.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final ctrl = widget.controller ?? GrievanceController.instance;
    await ctrl.reopenGrievance(
      id: widget.grievanceId,
      reason: _selectedReason!,
      details: _detailsController.text.trim(),
      attachments: _evidenceList,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Reopen request submitted for review.'),
        ),
      );
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  GrievanceHeader(
                    title: 'Reopen Grievance',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reference card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grievance Reference',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.grievanceReference,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 1. Reason for Reopening *
                      const Text(
                        'Reason for Reopening *',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedReason,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          hintText: 'Select reason',
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
                        items: _reopenReasons
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedReason = val),
                        validator: (val) =>
                            val == null ? 'Please select a reason' : null,
                      ),
                      const SizedBox(height: 14),

                      // 2. Additional Details *
                      const Text(
                        'Additional Details *',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _detailsController,
                        maxLines: 4,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Describe the remaining issue...',
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
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
                            return 'Please provide additional details';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 3. Supporting Evidence
                      const Text(
                        'Supporting Evidence',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          ..._evidenceList.asMap().entries.map((entry) {
                            final idx = entry.key;
                            return Stack(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondarySurface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 14,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _evidenceList.removeAt(idx)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 10,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          InkWell(
                            onTap: _addEvidence,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Request Reopen Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReopenRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          'Request Reopen',
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
  }
}
