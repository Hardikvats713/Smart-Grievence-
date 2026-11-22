/// Environment-based configuration for Google Maps & Places APIs.
/// Keys are provided via `--dart-define` at compile or run time.
/// NEVER hardcode production keys in source control.
abstract final class AppConfig {
  /// Google Maps Android / iOS SDK API Key.
  /// Pass via: `flutter run --dart-define=GOOGLE_MAPS_API_KEY=AIzaSy...`
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Google Places & Geocoding Web Service API Key (can be separate restricted key).
  /// Pass via: `flutter run --dart-define=GOOGLE_PLACES_API_KEY=AIzaSy...`
  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: googleMapsApiKey,
  );

  /// Checks if a valid Google Maps API key has been supplied.
  static bool get hasGoogleMapsKey => googleMapsApiKey.trim().isNotEmpty;

  /// Checks if a valid Google Places API key has been supplied.
  static bool get hasGooglePlacesKey => googlePlacesApiKey.trim().isNotEmpty;

  /// Default region coordinates (Itanagar Capital Complex, Arunachal Pradesh)
  static const double defaultLatitude = 27.1025;
  static const double defaultLongitude = 93.6160;
  static const double defaultZoom = 15.0;
}
