import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Top bar with back button, center/left title, and Deep Teal icons.
class GrievanceHeader extends StatelessWidget {
  const GrievanceHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (showBackButton)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
