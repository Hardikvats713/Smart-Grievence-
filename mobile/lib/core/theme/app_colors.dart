import 'package:flutter/material.dart';

/// Approved brand palette from docs/02_DESIGN_SYSTEM.md and design/design_tokens.json.
/// Do not alter these values without explicit approval.
abstract final class AppColors {
  // Brand palette — locked
  static const Color background = Color(0xFFF3EEE8); // Warm Ivory
  static const Color primary = Color(0xFF17645F); // Deep Teal Green
  static const Color accent = Color(0xFFE46A3D); // Burnt Ember
  static const Color secondarySurface = Color(0xFFDDEEE9); // Mint Sage
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF263B38);
  static const Color secondaryText = Color(0xFF78847F);
  static const Color border = Color(0xFFE5E9E6);
  static const Color disabled = Color(0xFFB8C2BE);

  // Semantic colors
  static const Color success = Color(0xFF368568);
  static const Color warning = Color(0xFFD9A441);
  static const Color error = Color(0xFFC94D4D);
  static const Color information = Color(0xFF5189B5);
}

