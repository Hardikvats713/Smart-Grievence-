import 'package:flutter/foundation.dart';

/// Abstract contract for retrieving supported administrative districts/cities.
/// Replace with a remote API client when the municipal backend service is available.
abstract class DistrictProvider {
  /// Fetches the list of approved districts or cities.
  Future<List<String>> getDistricts();
}

/// Initial configured administrative data provider.
///
/// If backend service is not yet configured, provides the standard administrative
/// division districts and logs the dependency.
class ConfiguredDistrictProvider implements DistrictProvider {
  const ConfiguredDistrictProvider({List<String>? initialDistricts})
      : _districts = initialDistricts;

  final List<String>? _districts;

  static const List<String> defaultDistricts = [
    'Central District',
    'East District',
    'North District',
    'North East District',
    'North West District',
    'Shahdara',
    'South District',
    'South East District',
    'South West District',
    'West District',
    'New Delhi',
  ];

  @override
  Future<List<String>> getDistricts() async {
    if (kDebugMode) {
      debugPrint(
        '[ConfiguredDistrictProvider] Loading administrative districts. '
        'Remote API integration pending backend deployment.',
      );
    }
    return _districts ?? defaultDistricts;
  }
}
