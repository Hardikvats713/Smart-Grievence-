import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/permission_service.dart';

/// A compact card displaying a single permission with icon, title,
/// description and a functional toggle switch.
class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.permissionState,
    required this.onToggle,
    this.compact = false,
  });

  /// Leading icon for this permission.
  final IconData icon;

  /// Permission title text.
  final String title;

  /// Short permission purpose description.
  final String description;

  /// Whether the citizen wants this permission enabled.
  final bool isEnabled;

  /// The actual OS-level permission state.
  final PermissionState permissionState;

  /// Called when the citizen taps the toggle.
  final VoidCallback onToggle;

  /// Whether to use extra compact vertical padding for smaller viewports.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool isPermanentlyDenied =
        permissionState == PermissionState.permanentlyDenied;

    return Container(
      constraints: BoxConstraints(
        minHeight: compact ? 60.0 : 68.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: const BoxDecoration(
              color: AppColors.secondarySurface, // Mint Sage
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: compact ? 18 : 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),

          // Title + Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPermanentlyDenied
                      ? 'Denied. Tap toggle to open settings.'
                      : description,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isPermanentlyDenied
                        ? AppColors.error
                        : AppColors.secondaryText,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Toggle switch
          SizedBox(
            height: 26,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: isEnabled,
                onChanged: (_) => onToggle(),
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor: AppColors.disabled,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
