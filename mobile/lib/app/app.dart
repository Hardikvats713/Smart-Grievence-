import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Root widget for the Smart Grievance application.
class SmartGrievanceApp extends StatelessWidget {
  const SmartGrievanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grievance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            // When previewed on desktop web / wide screens,
            // render within a compact Android smartphone frame.
            if (constraints.maxWidth > 360) {
              final double maxHeight = constraints.maxHeight;
              // Screen width increased by 10% (from 248dp to 273dp)
              const double androidWidth = 273.0;
              final double androidHeight = (maxHeight - 64).clamp(528.0, 594.0);

              const double safeTop = 24.0;
              const double safeBottom = 14.0;

              return Scaffold(
                backgroundColor: const Color(0xFF141C1B), // Dark slate backdrop
                body: Center(
                  child: Container(
                    width: androidWidth,
                    height: androidHeight,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF283633),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Main Android screen area
                        Positioned.fill(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: Size(androidWidth, androidHeight),
                              padding: const EdgeInsets.only(
                                top: safeTop,
                                bottom: safeBottom,
                              ),
                              viewPadding: const EdgeInsets.only(
                                top: safeTop,
                                bottom: safeBottom,
                              ),
                              devicePixelRatio: 2.0,
                              textScaler: const TextScaler.linear(0.90),
                            ),
                            child: child,
                          ),
                        ),

                        // Standard Android punch-hole front camera
                        Positioned(
                          top: 6,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1C2725).withValues(alpha: 0.9),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Standard Android gesture navigation bar pill
                        Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 55,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF263B38).withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // On actual mobile screens, render full-bleed with 10% reduced font size
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(0.90),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}
