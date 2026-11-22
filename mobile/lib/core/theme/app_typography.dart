import 'package:flutter/material.dart';

/// Typography scale from docs/02_DESIGN_SYSTEM.md.
/// Family: Poppins only.
abstract final class AppTypography {
  static const String _fontFamily = 'Poppins';

  /// Display / greeting: 28 px, 700, line-height 1.25
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// Screen heading: 22 px, 600, line-height 1.25
  static const TextStyle screenHeading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Section heading: 18 px, 600, line-height 1.25
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Card heading: 16 px, 500, line-height 1.25
  static const TextStyle cardHeading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  /// Body: 14 px, 400, line-height 1.5
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Supporting: 12 px, 400, line-height 1.4
  static const TextStyle supporting = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Button: 15 px, 600
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Metadata: 11 px, 500
  static const TextStyle metadata = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}

