import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../grievances/widgets/grievance_header.dart';

/// Screen 18 — How It Works.
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      _HowItWorksStep(
        stepNumber: '1',
        title: 'Report an Issue',
        description:
            'Select a category, describe the problem, add evidence and provide its location.',
        icon: Icons.edit_note_rounded,
      ),
      _HowItWorksStep(
        stepNumber: '2',
        title: 'Grievance Verification',
        description:
            'The responsible department reviews your submitted grievance.',
        icon: Icons.verified_outlined,
      ),
      _HowItWorksStep(
        stepNumber: '3',
        title: 'Action & Resolution',
        description:
            'The grievance is assigned to the appropriate authority for investigation and action.',
        icon: Icons.engineering_outlined,
      ),
      _HowItWorksStep(
        stepNumber: '4',
        title: 'Track Your Grievance',
        description:
            'Follow progress and receive updates until your grievance is resolved.',
        icon: Icons.track_changes_rounded,
        isLast: true,
      ),
    ];

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
                    title: 'How It Works',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  ...steps.map((s) => _StepRow(step: s)),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Submit a Grievance Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/submit-grievance');
                  },
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Submit a Grievance',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
  }
}

class _HowItWorksStep {
  const _HowItWorksStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.isLast = false,
  });

  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final _HowItWorksStep step;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Circle & Timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  step.stepNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (!step.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content Box
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: step.isLast ? 0 : 28),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(step.icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
