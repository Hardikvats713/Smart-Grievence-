import 'package:flutter/foundation.dart';

/// Result of an authentication operation (send OTP, resend OTP, verify OTP).
enum AuthResultStatus { success, failure, loading }

class AuthResult {
  const AuthResult({required this.status, this.message});
  final AuthResultStatus status;
  final String? message;

  bool get isSuccess => status == AuthResultStatus.success;
}

/// Abstract interface for authentication operations.
/// A real SMS/OTP provider (Firebase Auth, MSG91, Twilio, etc.) must implement this.
abstract class AuthController {
  /// Default resend cooldown in seconds.
  int get resendCooldownSeconds;

  /// Initiate OTP delivery to the given mobile number.
  Future<AuthResult> sendOtp(String phoneNumber);

  /// Resend OTP to the given mobile number.
  Future<AuthResult> resendOtp(String phoneNumber);

  /// Submit entered 6-digit OTP for backend verification.
  Future<AuthResult> verifyOtp(String phoneNumber, String otp);
}

/// Stub implementation — no production OTP provider is configured yet.
/// Replace with a real backend integration before release.
class StubAuthController implements AuthController {
  @override
  int get resendCooldownSeconds => 30;

  @override
  Future<AuthResult> sendOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (kDebugMode) {
      debugPrint('[StubAuthController] OTP requested for +91$phoneNumber');
    }
    return const AuthResult(
      status: AuthResultStatus.success,
      message: 'OTP initiated.',
    );
  }

  @override
  Future<AuthResult> resendOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (kDebugMode) {
      debugPrint('[StubAuthController] OTP resent for +91$phoneNumber');
    }
    return const AuthResult(
      status: AuthResultStatus.success,
      message: 'New OTP sent.',
    );
  }

  @override
  Future<AuthResult> verifyOtp(String phoneNumber, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (kDebugMode) {
      debugPrint('[StubAuthController] Verifying OTP for +91$phoneNumber');
    }

    // Specific error simulation for testing/demo purposes
    if (otp == '000000') {
      return const AuthResult(
        status: AuthResultStatus.failure,
        message: 'Invalid or expired OTP. Please try again.',
      );
    }

    return const AuthResult(
      status: AuthResultStatus.success,
      message: 'Verification successful.',
    );
  }
}

/// Validates an Indian mobile number.
/// Returns null when valid; otherwise returns an error string.
String? validateIndianMobile(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Please enter your mobile number';
  if (trimmed.length != 10) return 'Enter a valid 10-digit mobile number';
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
    return 'Enter a valid Indian mobile number';
  }
  return null;
}

/// Formats a 10-digit Indian mobile number for display, e.g. "+91 98765 43210".
String formatIndianMobile(String rawNumber) {
  final digits = rawNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  } else if (digits.length > 10 && digits.startsWith('91')) {
    final local = digits.substring(digits.length - 10);
    return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
  }
  return rawNumber.isEmpty ? '+91' : '+91 $rawNumber';
}
