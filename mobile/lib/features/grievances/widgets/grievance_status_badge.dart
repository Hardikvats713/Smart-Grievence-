import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/grievance_model.dart';

/// Reusable status badge with approved semantic coloring.
class GrievanceStatusBadge extends StatelessWidget {
  const GrievanceStatusBadge({
    super.key,
    required this.status,
  });

  final GrievanceStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case GrievanceStatus.inProgress:
      case GrievanceStatus.underReview:
      case GrievanceStatus.resolutionProposed:
      case GrievanceStatus.reopened:
        bg = const Color(0xFFFEF3DE);
        fg = AppColors.warning;
        break;
      case GrievanceStatus.resolved:
        bg = const Color(0xFFE8F6EF);
        fg = AppColors.success;
        break;
      case GrievanceStatus.submitted:
        bg = const Color(0xFFEBF3F9);
        fg = AppColors.information;
        break;
      case GrievanceStatus.assigned:
        bg = AppColors.secondarySurface;
        fg = AppColors.primary;
        break;
      case GrievanceStatus.rejected:
        bg = const Color(0xFFFDEBEB);
        fg = AppColors.error;
        break;
      case GrievanceStatus.closed:
        bg = const Color(0xFFECEFF0);
        fg = AppColors.secondaryText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
