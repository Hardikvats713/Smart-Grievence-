import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/dashboard_controller.dart';
import '../widgets/dashboard_bottom_navigation.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/submit_grievance_card.dart';
import '../widgets/welcome_section.dart';

/// Screen 07 — Citizen Home Dashboard.
///
/// Main landing screen with full routing integration to Screens 08 to 16:
/// - Smart Grievance logo and notifications top bar
/// - Welcome greeting for the citizen
/// - Prominent Submit a Grievance CTA card (navigates to Screen 08)
/// - 2x2 grid of quick-action cards (navigates to Screens 13, 15, etc.)
/// - Decorative bottom-right wave
/// - Fixed 4-tab bottom navigation (Home, Grievance, Map, Profile)
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    this.controller,
  });

  final DashboardController? controller;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DashboardController();
    _controller.addListener(_onControllerChanged);
    _controller.loadDashboardData();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _showFeaturePlaceholder(String featureName, String routeName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        content: Text(
          '$featureName ($routeName) is scheduled for subsequent release.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Bottom-Right Decorative Wave ──────────────────────────────
          // Positioned behind content at the bottom right, enlarged by ~60% (150 -> 240)
          Positioned(
            right: -10,
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.92,
                child: Image.asset(
                  'assets/images/dashboard_bottom_right_wave.png',
                  width: 240,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Main Dashboard Content ────────────────────────────────────
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableHeight = constraints.maxHeight;
                final bool isShortScreen = availableHeight < 640;

                // Dynamically calculate downward shift based on available viewport height
                // ensuring the 4 features cards rest directly over/touching the bottom wave
                final double topSpacer = (availableHeight - 480).clamp(24.0, 95.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Header: Logo & Notifications
                      DashboardHeader(
                        unreadCount: state.unreadNotificationCount,
                        onNotificationTap: () =>
                            Navigator.of(context).pushNamed('/notifications'),
                      ),

                      // Significant downward shift so features cards touch the wave
                      SizedBox(height: topSpacer),

                      // Welcome Section with Cityscape Illustration
                      WelcomeSection(
                        citizenName: state.citizenName,
                      ),

                      SizedBox(height: isShortScreen ? 16 : 24),

                      // Primary Call to Action: Submit Grievance (Screen 08)
                      SubmitGrievanceCard(
                        onTap: () => Navigator.of(context).pushNamed('/submit-grievance'),
                      ),

                      // Spacing before 2x2 grid
                      SizedBox(height: isShortScreen ? 20 : 32),

                      // 2x2 Quick Action Grid
                      QuickActionGrid(
                        onTrackGrievancesTap: () =>
                            Navigator.of(context).pushNamed('/my-grievances'),
                        onGrievanceMapTap: () =>
                            Navigator.of(context).pushNamed('/grievance-map'),
                        onViewUpdatesTap: () => _showFeaturePlaceholder(
                          'View Updates',
                          '/updates',
                        ),
                        onHowItWorksTap: () =>
                            Navigator.of(context).pushNamed('/how-it-works'),
                      ),

                      const SizedBox(height: 20),
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Fixed Bottom Navigation Bar ───────────────────────────────
      bottomNavigationBar: DashboardBottomNavigation(
        selectedIndex: _controller.selectedTabIndex,
        onTabSelected: (index) {
          _controller.setTabIndex(index);
          switch (index) {
            case 0:
              // Home tab
              break;
            case 1:
              Navigator.of(context).pushNamed('/my-grievances');
              break;
            case 2:
              Navigator.of(context).pushNamed('/grievance-map');
              break;
            case 3:
              Navigator.of(context).pushNamed('/profile');
              break;
          }
        },
      ),
    );
  }
}
