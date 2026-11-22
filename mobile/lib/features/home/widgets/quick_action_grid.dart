import 'package:flutter/material.dart';
import 'quick_action_card.dart';

/// 2-column by 2-row grid of compact quick-action cards.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.onTrackGrievancesTap,
    required this.onGrievanceMapTap,
    required this.onViewUpdatesTap,
    required this.onHowItWorksTap,
  });

  final VoidCallback onTrackGrievancesTap;
  final VoidCallback onGrievanceMapTap;
  final VoidCallback onViewUpdatesTap;
  final VoidCallback onHowItWorksTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 58,
                child: QuickActionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Track My Grievances',
                  onTap: onTrackGrievancesTap,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 58,
                child: QuickActionCard(
                  icon: Icons.map_outlined,
                  title: 'Grievance Map',
                  onTap: onGrievanceMapTap,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 58,
                child: QuickActionCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'View Updates',
                  onTap: onViewUpdatesTap,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 58,
                child: QuickActionCard(
                  icon: Icons.info_outline_rounded,
                  title: 'How It Works',
                  onTap: onHowItWorksTap,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

