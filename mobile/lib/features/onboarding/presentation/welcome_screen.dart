import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/onboarding_slide.dart';

/// Screen 02 — Animated Onboarding Carousel.
///
/// Features:
/// - Three-slide carousel (`PageView`) showcasing civic grievance journey.
/// - 3-second automatic horizontal slide transitions (order: 1 → 2 → 3 → 1).
/// - Lifecycle-safe timer that pauses in background and resumes on return.
/// - 3 interactive pagination dots with Burnt Ember `#E46A3D` active state.
/// - Manual dot tap & swipe navigation, resetting the 3s interval.
/// - "Get Started →" advances slides 1 & 2, and completes on slide 3.
/// - "Skip" navigates directly to the authentication flow from any slide.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.autoPlay = true,
    this.slides = OnboardingContent.slides,
  });

  /// Whether the carousel should automatically advance every 3 seconds.
  /// Set to `false` in deterministic tests when timers are manually pumped.
  final bool autoPlay;

  /// Centralised list of slides. Defaults to [OnboardingContent.slides].
  final List<OnboardingSlide> slides;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  static const Duration _autoSlideInterval = Duration(seconds: 3);
  static const Duration _transitionDuration = Duration(milliseconds: 450);
  static const Curve _transitionCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);

    if (widget.autoPlay) {
      _startTimer();
    }
  }

  void _startTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(_autoSlideInterval, (_) {
      _advanceAutomatically();
    });
  }

  void _stopTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  void _resetTimer() {
    if (!widget.autoPlay) return;
    _stopTimer();
    _startTimer();
  }

  void _advanceAutomatically() {
    if (!mounted || !_pageController.hasClients) return;
    final int next = (_currentPage + 1) % widget.slides.length;
    _pageController.animateToPage(
      next,
      duration: _transitionDuration,
      curve: _transitionCurve,
    );
  }

  void _goToPage(int page) {
    if (!mounted || !_pageController.hasClients) return;
    _pageController.animateToPage(
      page,
      duration: _transitionDuration,
      curve: _transitionCurve,
    );
    _resetTimer();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() {
      _currentPage = index;
    });
    _resetTimer();
  }

  void _onGetStartedPressed() {
    if (_currentPage < widget.slides.length - 1) {
      // Slides 1 & 2 advance to the next slide
      _goToPage(_currentPage + 1);
    } else {
      // Slide 3 navigates to the next flow (authentication placeholder)
      _navigateToAuthFlow();
    }
  }

  void _onSkipPressed() {
    // Skip navigates directly to authentication flow from any slide
    _navigateToAuthFlow();
  }

  void _navigateToAuthFlow() {
    _stopTimer();
    Navigator.of(context).pushReplacementNamed(AppRouter.authPlaceholder);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.autoPlay) return;
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);

    // Responsive illustration constraint
    final double maxIllustrationHeight =
        (screenSize.height * 0.44).clamp(180.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Carousel View (Title, Description, Illustration) ──────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.slides.length,
                itemBuilder: (context, index) {
                  final slide = widget.slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Slide Heading
                        Text(
                          slide.heading,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppColors.primary, // Deep Teal Green
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Slide Description
                        Text(
                          slide.description,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                            color: AppColors.primaryText,
                          ),
                        ),

                        // Slide Illustration
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: maxIllustrationHeight,
                                maxWidth: double.infinity,
                              ),
                              child: Semantics(
                                label: slide.semanticsLabel,
                                image: true,
                                child: Image.asset(
                                  slide.imageAsset,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Pagination Indicators (3 Tappable Dots) ────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.slides.length, (index) {
                  final bool isActive = index == _currentPage;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _goToPage(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 8,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isActive ? 10 : 7,
                        height: isActive ? 10 : 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.accent // Burnt Ember #E46A3D
                              : const Color(0xFFCADBD6), // Muted light grey-green
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Bottom Navigation Controls ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary Action Button ("Get Started →")
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary, // Deep Teal Green
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26), // Smooth pill
                        ),
                        elevation: 0,
                      ),
                      onPressed: _onGetStartedPressed,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Secondary Action ("Skip")
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(64, 36),
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: _onSkipPressed,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: (safePadding.bottom > 0 ? safePadding.bottom : 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
