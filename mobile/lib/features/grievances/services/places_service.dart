import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

/// Place suggestion entity returned by autocomplete search.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.id,
    required this.name,
    required this.area,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    this.isGooglePlace = false,
  });

  final String id;
  final String name;
  final String area;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final bool isGooglePlace;

  PlaceSuggestion copyWith({
    double? latitude,
    double? longitude,
  }) {
    return PlaceSuggestion(
      id: id,
      name: name,
      area: area,
      fullAddress: fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isGooglePlace: isGooglePlace,
    );
  }
}

/// Real-time Google Places Autocomplete & Geocoding Service with local civic database fallback.
class PlacesService {
  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Curated regional civic database for Itanagar Capital Complex, Arunachal Pradesh.
  static const List<PlaceSuggestion> civicLandmarks = [
    PlaceSuggestion(
      id: 'civic-1',
      name: 'Bank Tinali (Clock Tower)',
      area: 'Commercial Hub',
      fullAddress: 'Bank Tinali, VIP Road, Itanagar, Arunachal Pradesh',
      latitude: 27.0984,
      longitude: 93.6288,
    ),
    PlaceSuggestion(
      id: 'civic-2',
      name: 'Civil Secretariat',
      area: 'Administrative Zone',
      fullAddress: 'Civil Secretariat, Itanagar, Arunachal Pradesh',
      latitude: 27.0935,
      longitude: 93.6133,
    ),
    PlaceSuggestion(
      id: 'civic-3',
      name: 'Ganga Lake (Gyakar Sinyi)',
      area: 'Ganga Lake View Point',
      fullAddress: 'Ganga Lake View Point, Ganga, Itanagar, Arunachal Pradesh',
      latitude: 27.0867,
      longitude: 93.5954,
    ),
    PlaceSuggestion(
      id: 'civic-4',
      name: 'Heema Hospital Road',
      area: 'Sector A, Medical Zone',
      fullAddress: 'Heema Hospital Road, Sector A, Itanagar, Arunachal Pradesh',
      latitude: 27.1051,
      longitude: 93.6212,
    ),
    PlaceSuggestion(
      id: 'civic-5',
      name: 'Daily Market Complex, Sector 12',
      area: 'Daily Bazaar Area',
      fullAddress: 'Market Complex, Sector 12, Itanagar, Arunachal Pradesh',
      latitude: 27.1010,
      longitude: 93.6190,
    ),
    PlaceSuggestion(
      id: 'civic-6',
      name: 'Donyi Polo Airport Road',
      area: 'Hollongi Terminal Road',
      fullAddress: 'Donyi Polo Airport Road, Hollongi, Arunachal Pradesh',
      latitude: 26.9950,
      longitude: 93.6420,
    ),
    PlaceSuggestion(
      id: 'civic-7',
      name: 'Raj Bhavan Road',
      area: 'VIP Hills, Itanagar',
      fullAddress: 'Raj Bhavan Road, VIP Hills, Itanagar, Arunachal Pradesh',
      latitude: 27.1120,
      longitude: 93.6080,
    ),
    PlaceSuggestion(
      id: 'civic-8',
      name: 'Niti Vihar Main Road',
      area: 'Residential Colony',
      fullAddress: 'Niti Vihar Main Road, Itanagar, Arunachal Pradesh',
      latitude: 27.0955,
      longitude: 93.6250,
    ),
    PlaceSuggestion(
      id: 'civic-9',
      name: 'Chimpu Police Station',
      area: 'NH-415 Highway Junction',
      fullAddress: 'Chimpu Police Station, NH-415, Itanagar, Arunachal Pradesh',
      latitude: 27.0720,
      longitude: 93.6020,
    ),
    PlaceSuggestion(
      id: 'civic-10',
      name: 'Polo Park & Botanical Garden',
      area: 'Naharlagun Hills',
      fullAddress: 'Polo Park, Naharlagun, Arunachal Pradesh',
      latitude: 27.1040,
      longitude: 93.6880,
    ),
    PlaceSuggestion(
      id: 'civic-11',
      name: 'Naharlagun Railway Station',
      area: 'Transport Hub',
      fullAddress: 'Naharlagun Railway Station, Naharlagun, Arunachal Pradesh',
      latitude: 27.1280,
      longitude: 93.6920,
    ),
    PlaceSuggestion(
      id: 'civic-12',
      name: 'TRIHMS Hospital',
      area: 'Medical College Zone',
      fullAddress: 'Tomo Riba Institute (TRIHMS), Naharlagun, Arunachal Pradesh',
      latitude: 27.1120,
      longitude: 93.6840,
    ),
    PlaceSuggestion(
      id: 'civic-13',
      name: 'NERIST Campus, Nirjuli',
      area: 'Education Hub',
      fullAddress: 'NERIST Campus, Nirjuli, Arunachal Pradesh',
      latitude: 27.1350,
      longitude: 93.7420,
    ),
  ];

  /// Queries Google Places Autocomplete API when configured, falling back to civic landmarks.
  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return civicLandmarks;
    }

    if (AppConfig.hasGooglePlacesKey) {
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=${Uri.encodeComponent(cleanQuery)}&'
          'components=country:in&'
          'location=27.1025,93.6160&radius=50000&'
          'key=${AppConfig.googlePlacesApiKey}',
        );

        final response = await _client.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final predictions = data['predictions'] as List<dynamic>?;
          if (predictions != null && predictions.isNotEmpty) {
            return predictions.map((p) {
              final placeId = p['place_id'] as String? ?? 'p-${DateTime.now().millisecondsSinceEpoch}';
              final desc = p['description'] as String? ?? cleanQuery;
              final structured = p['structured_formatting'] as Map<String, dynamic>?;
              final mainText = structured?['main_text'] as String? ?? desc.split(',').first;
              final secondaryText = structured?['secondary_text'] as String? ?? 'Arunachal Pradesh, India';

              return PlaceSuggestion(
                id: placeId,
                name: mainText,
                area: secondaryText,
                fullAddress: desc,
                isGooglePlace: true,
              );
            }).toList();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PlacesService] Google Places Autocomplete query failed: $e');
        }
      }
    }

    // Local matching fallback
    final q = cleanQuery.toLowerCase();
    return civicLandmarks.where((place) {
      return place.name.toLowerCase().contains(q) ||
          place.area.toLowerCase().contains(q) ||
          place.fullAddress.toLowerCase().contains(q);
    }).toList();
  }

  /// Resolves exact lat/lng coordinates for a Google Place ID or returns existing coordinates.
  Future<PlaceSuggestion> resolveCoordinates(PlaceSuggestion suggestion) async {
    if (suggestion.latitude != null && suggestion.longitude != null) {
      return suggestion;
    }

    if (suggestion.isGooglePlace && AppConfig.hasGooglePlacesKey) {
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=${suggestion.id}&'
          'fields=geometry,formatted_address,name&'
          'key=${AppConfig.googlePlacesApiKey}',
        );

        final response = await _client.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final result = data['result'] as Map<String, dynamic>?;
          final location = result?['geometry']?['location'] as Map<String, dynamic>?;
          if (location != null) {
            final double lat = (location['lat'] as num).toDouble();
            final double lng = (location['lng'] as num).toDouble();
            final formatted = result?['formatted_address'] as String? ?? suggestion.fullAddress;

            return PlaceSuggestion(
              id: suggestion.id,
              name: suggestion.name,
              area: suggestion.area,
              fullAddress: formatted,
              latitude: lat,
              longitude: lng,
              isGooglePlace: true,
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PlacesService] Google Place Details failed: $e');
        }
      }
    }

    // Default to nearest civic coordinate or Itanagar center
    return suggestion.copyWith(
      latitude: AppConfig.defaultLatitude,
      longitude: AppConfig.defaultLongitude,
    );
  }

  /// Reverse geocodes coordinates to a human-readable street address.
  Future<String> reverseGeocode(double latitude, double longitude) async {
    if (AppConfig.hasGooglePlacesKey) {
      try {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?'
          'latlng=$latitude,$longitude&'
          'key=${AppConfig.googlePlacesApiKey}',
        );

        final response = await _client.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final results = data['results'] as List<dynamic>?;
          if (results != null && results.isNotEmpty) {
            final formatted = results.first['formatted_address'] as String?;
            if (formatted != null && formatted.isNotEmpty) {
              return formatted;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[PlacesService] Google Reverse Geocoding failed: $e');
        }
      }
    }

    // Find closest local landmark
    PlaceSuggestion? closest;
    double minDistance = double.infinity;
    for (final landmark in civicLandmarks) {
      if (landmark.latitude != null && landmark.longitude != null) {
        final dLat = landmark.latitude! - latitude;
        final dLng = landmark.longitude! - longitude;
        final dist = math.sqrt(dLat * dLat + dLng * dLng);
        if (dist < minDistance) {
          minDistance = dist;
          closest = landmark;
        }
      }
    }

    if (closest != null && minDistance < 0.015) {
      return 'Near ${closest.name}, ${closest.area}, Itanagar, Arunachal Pradesh';
    }

    return 'Sector Road, Itanagar, Arunachal Pradesh (${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E)';
  }
}
