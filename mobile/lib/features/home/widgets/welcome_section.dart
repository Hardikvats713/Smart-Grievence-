import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Compact welcome greeting section with the approved small cityscape
/// illustration positioned on the right, matching the reference design.
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({
    super.key,
    this.citizenName,
  });

  final String? citizenName;

  @override
  Widget build(BuildContext context) {
    final String trimmed = citizenName?.trim() ?? '';
    final bool isInvalid = trimmed.isEmpty ||
        trimmed.length < 2 ||
        trimmed.toLowerCase() == 'vc' ||
        trimmed.toLowerCase() == 'mhnqf';
    final String greeting = !isInvalid ? 'Hello, $trimmed!' : 'Hello, Citizen!';

    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background cityscape illustration on the right
          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: 140,
              height: 70,
              child: Image.asset(
                'assets/images/splash_cityscape.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),

          // Greeting & Description in foreground (can slightly overlay cityscape)
          Positioned(
            left: 0,
            top: 0,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Greeting on exact single line: "Hello, <User>!"
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),

                // Description on two controlled lines directly under the name
                const SizedBox(
                  width: 220,
                  child: Text(
                    'Your voice matters. Report an issue and get it resolved.',
                    maxLines: 2,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


