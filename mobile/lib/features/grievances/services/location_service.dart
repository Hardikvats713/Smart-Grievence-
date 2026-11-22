import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// GPS location result entity.
class GpsLocationResult {
  const GpsLocationResult({
    this.latitude,
    this.longitude,
    this.isSuccess = false,
    this.errorMessage,
  });

  final double? latitude;
  final double? longitude;
  final bool isSuccess;
  final String? errorMessage;
}

/// Service managing device location permissions and real GPS coordinate acquisition.
class LocationService {
  const LocationService();

  /// Requests location permissions and fetches the citizen's current device coordinates.
  Future<GpsLocationResult> getCurrentPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const GpsLocationResult(
          isSuccess: false,
          errorMessage: 'Location services are disabled on your device. Please turn on GPS.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const GpsLocationResult(
            isSuccess: false,
            errorMessage: 'Location permission was denied. You can still select your location on the map.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const GpsLocationResult(
          isSuccess: false,
          errorMessage: 'Location permission is permanently denied. Please allow location in system settings.',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      return GpsLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isSuccess: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocationService] Failed to acquire GPS position: $e');
      }
      return GpsLocationResult(
        isSuccess: false,
        errorMessage: 'Unable to detect GPS position ($e). Using default city coordinates.',
      );
    }
  }
}
