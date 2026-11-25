import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import 'auth_controller.dart';

/// Production AuthController backed by `/api/v1/auth/*` REST API.
/// Gracefully handles offline/local testing if backend is unreachable.
class RemoteAuthController implements AuthController {
  @override
  int get resendCooldownSeconds => 30;

  @override
  Future<AuthResult> sendOtp(String phoneNumber) async {
    final normalized = phoneNumber.startsWith('+91') ? phoneNumber : '+91$phoneNumber';
    final res = await ApiClient.post(
      '/auth/send-otp',
      {'phoneNumber': normalized},
      includeAuth: false,
    );

    if (res.success) {
      return AuthResult(status: AuthResultStatus.success, message: res.message);
    }

    // Fallback to offline stub in debug/test mode if server isn't running
    final isOfflineOrTest = res.statusCode == 503 ||
        (res.statusCode == 400 && res.message.startsWith('Invalid server response'));
    if (kDebugMode && isOfflineOrTest) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return const AuthResult(
        status: AuthResultStatus.success,
        message: 'OTP initiated (Offline Demo Mode).',
      );
    }

    return AuthResult(status: AuthResultStatus.failure, message: res.message);
  }

  @override
  Future<AuthResult> resendOtp(String phoneNumber) => sendOtp(phoneNumber);

  @override
  Future<AuthResult> verifyOtp(String phoneNumber, String otp) async {
    final normalized = phoneNumber.startsWith('+91') ? phoneNumber : '+91$phoneNumber';
    final res = await ApiClient.post(
      '/auth/verify-otp',
      {
        'phoneNumber': normalized,
        'otp': otp,
      },
      includeAuth: false,
    );

    if (res.success && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final accessToken = data['accessToken']?.toString() ?? '';
      final refreshToken = data['refreshToken']?.toString() ?? '';
      final activeRole = user['primaryRole']?.toString() ?? 'CITIZEN';
      final rawRoles = user['roles'] as List<dynamic>? ?? [activeRole];
      final roles = rawRoles.map((e) => e.toString()).toList();
      final deptId = user['departmentId']?.toString();

      await ApiClient.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        activeRole: activeRole,
        roles: roles,
        departmentId: deptId,
      );

      return AuthResult(status: AuthResultStatus.success, message: res.message);
    }

    // Fallback for offline/test demo mode
    final isOfflineOrTest = res.statusCode == 503 ||
        (res.statusCode == 400 && res.message.startsWith('Invalid server response'));
    if (kDebugMode && isOfflineOrTest) {
      if (otp == '000000') {
        return const AuthResult(
          status: AuthResultStatus.failure,
          message: 'Invalid or expired OTP. Please try again.',
        );
      }
      return const AuthResult(
        status: AuthResultStatus.success,
        message: 'Verification successful (Offline Demo Mode).',
      );
    }

    return AuthResult(status: AuthResultStatus.failure, message: res.message);
  }
}
