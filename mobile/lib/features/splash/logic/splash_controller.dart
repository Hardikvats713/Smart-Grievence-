import 'package:flutter/foundation.dart';

/// Handles splash-screen initialization logic.
///
/// Currently performs a placeholder authentication-state check.
/// When a real auth service is integrated, replace [_checkAuthState]
/// with actual credential / token validation.
///
/// TEMPORARY ROUTING PLACEHOLDER:
/// [isAuthenticated] always returns `false` because no auth backend
/// exists yet. This will route every launch to the Welcome Screen once
/// that screen is built.
class SplashController {
  /// Whether the app has finished its startup work.
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  /// Result of the auth-state check. `null` until initialization completes.
  bool? get isAuthenticated => _isAuthenticated;
  bool? _isAuthenticated;

  /// Performs all genuine startup work:
  /// 1. Pre-cache resources (if any).
  /// 2. Check authentication state.
  ///
  /// Returns when initialization is done. Does NOT add artificial delays.
  Future<void> initialize() async {
    try {
      await _checkAuthState();
      _isInitialized = true;
    } catch (e) {
      // Log and surface the error; do not silently swallow.
      debugPrint('SplashController.initialize failed: $e');
      _isInitialized = true; // Allow navigation so the user isn't stuck.
      _isAuthenticated = false;
    }
  }

  /// TEMPORARY PLACEHOLDER — replace with real auth-state check.
  ///
  /// When a real auth service exists, this should:
  /// - Read stored tokens / session.
  /// - Validate token expiry or call a lightweight /me endpoint.
  /// - Set [_isAuthenticated] accordingly.
  Future<void> _checkAuthState() async {
    // TODO(auth): Replace with actual authentication-state check.
    // No artificial delay is added; the future resolves immediately.
    _isAuthenticated = false;
  }
}

