import 'package:flutter/foundation.dart';

/// User profile domain entity.
class UserProfile {
  const UserProfile({
    required this.fullName,
    this.email,
    required this.district,
    required this.phoneNumber,
    this.photoBytes,
    this.photoPath,
  });

  final String fullName;
  final String? email;
  final String district;
  final String phoneNumber;
  final Uint8List? photoBytes;
  final String? photoPath;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'district': district,
        'phoneNumber': phoneNumber,
        'hasPhoto': photoBytes != null || photoPath != null,
      };
}

/// Result of a profile save or update operation.
class ProfileResult {
  const ProfileResult({
    required this.isSuccess,
    this.message,
  });

  final bool isSuccess;
  final String? message;
}

/// Abstract contract for profile persistence and management.
abstract class ProfileController {
  Future<ProfileResult> saveProfile(UserProfile profile);
  UserProfile? get currentProfile;
}

/// Stub implementation for development and testing.
/// Replace with a real REST/GraphQL client when the backend is ready.
class StubProfileController implements ProfileController {
  static UserProfile? _storedProfile;

  @override
  UserProfile? get currentProfile => _storedProfile;

  @override
  Future<ProfileResult> saveProfile(UserProfile profile) async {
    // Simulate brief network latency
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (kDebugMode) {
      debugPrint('[StubProfileController] Saving profile for ${profile.fullName} (+91 ${profile.phoneNumber})');
      debugPrint('[StubProfileController] District: ${profile.district}, Email: ${profile.email ?? "None"}');
    }

    if (profile.fullName.trim().isEmpty) {
      return const ProfileResult(
        isSuccess: false,
        message: 'Full name is required.',
      );
    }

    if (profile.district.trim().isEmpty) {
      return const ProfileResult(
        isSuccess: false,
        message: 'Please select your district.',
      );
    }

    _storedProfile = profile;
    return const ProfileResult(
      isSuccess: true,
      message: 'Profile saved successfully.',
    );
  }
}

/// Validates full name input.
String? validateFullName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Please enter your full name';
  }
  if (trimmed.length < 2) {
    return 'Full name must be at least 2 characters';
  }
  return null;
}

/// Validates optional email input.
String? validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null; // Email is optional
  }
  final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,6}$');
  if (!emailRegex.hasMatch(trimmed)) {
    return 'Please enter a valid email address';
  }
  return null;
}

/// Validates district selection.
String? validateDistrict(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Please select your district';
  }
  return null;
}

