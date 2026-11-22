import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 5-stage submission progress stepper per storyboard screens 08, 09, 10, 11:
/// Stages: 1. Category, 2. Details, 3. Location, 4. Review, 5. Submit.
class GrievanceStepProgressIndicator extends StatelessWidget {
  const GrievanceStepProgressIndicator({
    super.key,
    required this.currentStep,
  });

  /// 1-based index (1 to 5).
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const int totalSteps = 5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final int stepNumber = (index ~/ 2) + 1;
            final bool isPassedOrCurrent = stepNumber <= currentStep;
            final bool isCurrent = stepNumber == currentStep;

            return Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPassedOrCurrent ? AppColors.accent : AppColors.white,
                border: Border.all(
                  color: isPassedOrCurrent
                      ? AppColors.accent
                      : const Color(0xFFC8D3CE),
                  width: 2,
                ),
              ),
              child: isCurrent
                  ? Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  : null,
            );
          } else {
            final int segmentIndex = index ~/ 2;
            final bool isFilled = (segmentIndex + 1) < currentStep;

            return Expanded(
              child: Container(
                height: 2,
                color: isFilled ? AppColors.accent : const Color(0xFFD3DDD8),
              ),
            );
          }
        }),
      ),
    );
  }
}
