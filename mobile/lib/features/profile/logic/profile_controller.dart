import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class StubProfileController extends ChangeNotifier implements ProfileController {
  StubProfileController();

  static final StubProfileController instance = StubProfileController();

  static const String _prefFullName = 'sg_user_fullName';
  static const String _prefEmail = 'sg_user_email';
  static const String _prefDistrict = 'sg_user_district';
  static const String _prefPhone = 'sg_user_phone';
  static const String _prefPhotoPath = 'sg_user_photoPath';
  static const String _prefPhotoBase64 = 'sg_user_photoBase64';

  static UserProfile? _storedProfile = const UserProfile(
    fullName: 'Rahul Sharma',
    email: 'rahul.sharma@email.com',
    district: 'Papum Pare',
    phoneNumber: '9876543210',
  );

  @override
  UserProfile? get currentProfile => _storedProfile;

  /// Loads persisted citizen profile & avatar bytes from disk (SharedPreferences).
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefFullName);
      if (name != null && name.trim().isNotEmpty) {
        Uint8List? photoBytes;
        final b64 = prefs.getString(_prefPhotoBase64);
        if (b64 != null && b64.isNotEmpty) {
          try {
            photoBytes = base64Decode(b64);
          } catch (_) {}
        }

        _storedProfile = UserProfile(
          fullName: name,
          email: prefs.getString(_prefEmail),
          district: prefs.getString(_prefDistrict) ?? 'Papum Pare',
          phoneNumber: prefs.getString(_prefPhone) ?? '9876543210',
          photoPath: prefs.getString(_prefPhotoPath),
          photoBytes: photoBytes,
        );
        notifyListeners();
      }
    } catch (_) {
      // Handled silently during widget test / headless execution
    }
  }

  void clearSession() {
    _storedProfile = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_prefFullName);
      prefs.remove(_prefEmail);
      prefs.remove(_prefDistrict);
      prefs.remove(_prefPhone);
      prefs.remove(_prefPhotoPath);
      prefs.remove(_prefPhotoBase64);
    }).catchError((_) {});
    notifyListeners();
  }

  @override
  Future<ProfileResult> saveProfile(UserProfile profile) async {
    // Simulate brief network latency
    await Future<void>.delayed(const Duration(milliseconds: 300));

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

    // Persist to SharedPreferences so profile photo and data survive app restarts
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefFullName, profile.fullName);
      if (profile.email != null && profile.email!.isNotEmpty) {
        await prefs.setString(_prefEmail, profile.email!);
      } else {
        await prefs.remove(_prefEmail);
      }
      await prefs.setString(_prefDistrict, profile.district);
      await prefs.setString(_prefPhone, profile.phoneNumber);
      if (profile.photoPath != null && profile.photoPath!.isNotEmpty) {
        await prefs.setString(_prefPhotoPath, profile.photoPath!);
      } else {
        await prefs.remove(_prefPhotoPath);
      }
      if (profile.photoBytes != null && profile.photoBytes!.isNotEmpty) {
        await prefs.setString(_prefPhotoBase64, base64Encode(profile.photoBytes!));
      } else {
        await prefs.remove(_prefPhotoBase64);
      }
    } catch (_) {
      // Handled silently during pure unit tests without services binding
    }

    notifyListeners();
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

