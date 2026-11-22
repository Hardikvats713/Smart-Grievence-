import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/splash_controller.dart';

/// Screen 01 — Splash Screen.
///
/// Displays the Smart Grievance logo centered on a Warm Ivory background
/// with the cityscape illustration anchored to the bottom. A subtle
/// linear progress indicator shows while genuine initialization runs.
///
/// After initialization the controller determines whether the user is
/// authenticated and navigates accordingly. While no auth backend exists,
/// the controller always reports unauthenticated and routes to a
/// temporary placeholder (see [_navigateAfterInit]).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.controller,
    this.autoNavigate = true,
  });

  final SplashController? controller;

  /// If `true` (standard app launch sequence), navigates immediately after initialization.
  /// If `false` (preview mode), holds on the Splash Screen so UI reviewers can inspect it.
  final bool autoNavigate;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashController _controller;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SplashController();

    // Subtle fade-in + slight scale-in for the logo (300 ms).
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();

    _runInit();
  }

  Future<void> _runInit() async {
    await _controller.initialize();
    if (!mounted) return;

    if (widget.autoNavigate) {
      setState(() => _isLoading = false);
      _navigateAfterInit();
    }
  }

  /// Routes based on authentication state.
  ///
  /// TEMPORARY ROUTING PLACEHOLDER:
  /// Neither the Welcome Screen nor authenticated landing exist yet.
  /// Both routes push a minimal [_PlaceholderScreen] that states which
  /// destination should appear. Replace with real named routes when
  /// those screens are implemented.
  void _navigateAfterInit() {
    final bool authenticated = _controller.isAuthenticated ?? false;

    if (authenticated) {
      // TODO(nav): Replace with route to authenticated landing screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const _PlaceholderScreen(
            destination: 'Authenticated Landing Screen',
          ),
        ),
      );
    } else {
      // Navigates to Screen 02 — Welcome Screen
      Navigator.of(context).pushReplacementNamed(AppRouter.welcome);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);

    // Responsive constraints:
    // Logo width: 86% of screen width clamped between 190 and 300 lp for bolder, prominent brand presence.
    // Logo height: max 38% of screen height.
    final double logoWidth = (screenSize.width * 0.86).clamp(190.0, 300.0);
    final double maxLogoHeight = (screenSize.height * 0.38).clamp(130.0, 280.0);

    // Cityscape height: capped at 28% of screen height, anchored to bottom.
    final double maxCityHeight = (screenSize.height * 0.28).clamp(80.0, 200.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false, // Cityscape extends naturally to bottom edge.
        child: Column(
          children: [
            // ── Logo section ──────────────────────────────────────────
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Semantics(
                      label: 'Smart Grievance logo',
                      image: true,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: logoWidth,
                          maxHeight: maxLogoHeight,
                        ),
                        child: Image.asset(
                          'assets/images/smart_grievance_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Progress indicator ────────────────────────────────────
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                    width: (screenSize.width * 0.40).clamp(100.0, 160.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: const LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: AppColors.secondarySurface, // Mint Sage
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary, // Deep Teal Green
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Cityscape illustration ────────────────────────────────
            Padding(
              padding: EdgeInsets.only(bottom: safePadding.bottom),
              child: Semantics(
                label: 'Cityscape illustration with sunrise, buildings, '
                    'green bushes, rolling landscape and a large tree',
                image: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxCityHeight,
                    maxWidth: double.infinity,
                  ),
                  child: Image.asset(
                    'assets/images/splash_cityscape.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
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

// ---------------------------------------------------------------------------
// TEMPORARY ROUTING PLACEHOLDER
// ---------------------------------------------------------------------------
/// Shown after splash when the target screen has not been built yet.
/// As per Section 6 of the instructions:
/// "If the user is unauthenticated, navigate to the Welcome Screen.
///  If authentication is not yet implemented, use a clearly isolated
///  temporary routing placeholder and document it."
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.destination});

  final String destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initialization Complete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Startup check finished. User is unauthenticated.\n'
                'Per Section 6 of specifications, routed to:\n"$destination"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const SplashScreen(autoNavigate: false),
                    ),
                  );
                },
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                label: const Text(
                  'View Splash Screen',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

