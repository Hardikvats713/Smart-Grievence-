import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/permission_controller.dart';
import '../services/permission_service.dart';
import '../widgets/permission_card.dart';

/// Screen 08 — Allow Access / Permissions.
///
/// Presents three permission toggles (Location, Camera, Notifications)
/// with explanations. Built with a compact responsive layout so all
/// elements and the "Allow & Continue" button fit entirely on screen
/// without scrolling.
class AllowAccessScreen extends StatefulWidget {
  const AllowAccessScreen({
    super.key,
    this.permissionService,
  });

  /// Optional injected service for testing.
  final PermissionService? permissionService;

  @override
  State<AllowAccessScreen> createState() => _AllowAccessScreenState();
}

class _AllowAccessScreenState extends State<AllowAccessScreen> {
  late final PermissionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PermissionController(
      service: widget.permissionService ?? const StubPermissionService(),
    );
    _controller.addListener(_onControllerChanged);
    _controller.init();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onAllowAndContinue() async {
    await _controller.processAndContinue();
    if (!mounted) return;

    // Navigate to home placeholder (will be replaced with actual home route)
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableHeight = constraints.maxHeight;

            // Responsive sizing based on viewport height
            final bool isShortScreen = availableHeight < 640;
            final double horizontalPadding = isShortScreen ? 16.0 : 20.0;
            final double iconSize = isShortScreen ? 44.0 : 50.0;
            final double iconSymbolSize = isShortScreen ? 22.0 : 24.0;
            final double gapAfterIcon = isShortScreen ? 6.0 : 8.0;
            final double headingFontSize = isShortScreen ? 20.0 : 22.0;
            final double descFontSize = isShortScreen ? 12.0 : 13.0;
            final double gapBeforeCards = isShortScreen ? 10.0 : 14.0;
            final double cardGap = isShortScreen ? 6.0 : 8.0;
            final double gapBeforeButton = isShortScreen ? 10.0 : 14.0;
            final double buttonHeight = isShortScreen ? 46.0 : 50.0;
            final double bottomSpacing = isShortScreen
                ? 10.0
                : (safePadding.bottom > 0 ? safePadding.bottom : 14.0);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  // ── Top Bar: Back button ──────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primaryText,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),

                  // ── Top Icon Circle ───────────────────────────────────
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.white,
                      size: iconSymbolSize,
                    ),
                  ),

                  SizedBox(height: gapAfterIcon),

                  // ── Heading ───────────────────────────────────────────
                  Text(
                    'Allow Access',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: headingFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Supporting Description ────────────────────────────
                  Text(
                    'We need a few permissions to make\nyour experience better.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: descFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                      height: 1.35,
                    ),
                  ),

                  SizedBox(height: gapBeforeCards),

                  // ── Permission Cards ──────────────────────────────────
                  PermissionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    description: 'To capture the exact issue location',
                    isEnabled: _controller.locationEnabled,
                    permissionState: _controller.locationState,
                    compact: isShortScreen,
                    onToggle: () =>
                        _controller.togglePermission(AppPermission.location),
                  ),

                  SizedBox(height: cardGap),

                  PermissionCard(
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera',
                    description: 'To upload photos or videos',
                    isEnabled: _controller.cameraEnabled,
                    permissionState: _controller.cameraState,
                    compact: isShortScreen,
                    onToggle: () =>
                        _controller.togglePermission(AppPermission.camera),
                  ),

                  SizedBox(height: cardGap),

                  PermissionCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    description: 'To keep you updated on your grievances',
                    isEnabled: _controller.notificationsEnabled,
                    permissionState: _controller.notificationsState,
                    compact: isShortScreen,
                    onToggle: () =>
                        _controller.togglePermission(AppPermission.notifications),
                  ),

                  const Spacer(),

                  SizedBox(height: gapBeforeButton),

                  // ── Allow & Continue Button ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonHeight / 2),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          _controller.isProcessing ? null : _onAllowAndContinue,
                      child: _controller.isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Allow & Continue',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: bottomSpacing),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
