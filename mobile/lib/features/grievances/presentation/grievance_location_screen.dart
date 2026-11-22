import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/saved_addresses/saved_addresses_controller.dart';
import '../logic/grievance_controller.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_step_progress_indicator.dart';
import '../widgets/smart_google_map_view.dart';

/// Screen 10 — Submit Grievance: Location.
class GrievanceLocationScreen extends StatefulWidget {
  const GrievanceLocationScreen({
    super.key,
    this.controller,
  });

  final GrievanceController? controller;

  @override
  State<GrievanceLocationScreen> createState() => _GrievanceLocationScreenState();
}

class _GrievanceLocationScreenState extends State<GrievanceLocationScreen> {
  late final GrievanceController _controller;
  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = const LocationService();
  bool _isAcquiringLocation = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onNext() {
    if (!_controller.draft.isLocationConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please select or verify the grievance location on the map first.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed('/submit-grievance/review');
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isAcquiringLocation = true);
    final result = await _locationService.getCurrentPosition();
    if (mounted) {
      setState(() => _isAcquiringLocation = false);
      if (result.isSuccess && result.latitude != null && result.longitude != null) {
        final address = await _placesService.reverseGeocode(result.latitude!, result.longitude!);
        _controller.updateLocation(
          address: address,
          lat: result.latitude!,
          lng: result.longitude!,
          isConfirmed: true,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Current GPS coordinates detected and verified.'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(result.errorMessage ?? 'Could not acquire GPS position.'),
          ),
        );
      }
    }
  }

  void _onChangeLocationModal() {
    final savedAddresses = SavedAddressesController.instance.addresses;
    String searchQuery = '';
    List<PlaceSuggestion> searchResults = PlacesService.civicLandmarks;
    bool isSearching = false;
    String? apiError;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;

            return FractionallySizedBox(
              heightFactor: 0.85,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: bottomPadding + 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet pull handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Header Row with Expanded Title (Prevents horizontal RenderFlex overflow)
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Change Location / Landmark',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, size: 20, color: AppColors.secondaryText),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search Field with Debounced Places Autocomplete
                    TextField(
                      autofocus: false,
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                          isSearching = true;
                          apiError = null;
                        });

                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                          _placesService.searchPlacesDetailed(val).then((res) {
                            if (ctx.mounted) {
                              setModalState(() {
                                searchResults = res.suggestions;
                                apiError = res.apiErrorMessage;
                                isSearching = false;
                              });
                            }
                          });
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search landmark, sector, or street name...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        suffixIcon: isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setModalState(() {
                                        searchQuery = '';
                                        searchResults = PlacesService.civicLandmarks;
                                        apiError = null;
                                      });
                                    },
                                  )
                                : null,
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) async {
                        if (val.trim().isNotEmpty) {
                          _controller.updateLocation(
                            address: val.trim(),
                            lat: 27.1025,
                            lng: 93.6160,
                            isConfirmed: true,
                          );
                          Navigator.of(ctx).pop();
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Scrollable content area: contains GPS action, error banner, suggestions, and saved addresses
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // 1. Option to use device GPS directly
                          ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            tileColor: AppColors.secondarySurface,
                            leading: const Icon(Icons.my_location_rounded, color: AppColors.accent, size: 20),
                            title: const Text(
                              'Use Current Device Location',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            subtitle: const Text(
                              'Detect GPS sensor coordinates',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(ctx).pop();
                              await _detectCurrentLocation();
                            },
                          ),
                          const SizedBox(height: 12),

                          // 2. Informational Diagnostics Banner (if Google API is unbilled or denied)
                          if (apiError != null && searchQuery.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFD54F)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFF57F17)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Google Places Cloud Notice',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF57F17),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          apiError!.contains('Billing')
                                              ? 'Google Cloud project requires Billing activation for Google Places API. Showing live online search results via OpenStreetMap.'
                                              : apiError!,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // 3. Autocomplete Place Suggestions Header
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: 6),
                              Text(
                                searchQuery.isEmpty ? 'Suggested Civic Locations' : 'Matching Places (${searchResults.length})',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 4. Suggestion Items
                          if (searchResults.isNotEmpty)
                            ...searchResults.map((place) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                  tileColor: AppColors.white,
                                  leading: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondarySurface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  subtitle: Text(
                                    place.latitude != null && place.longitude != null
                                        ? '${place.area} • ${place.latitude!.toStringAsFixed(4)}° N, ${place.longitude!.toStringAsFixed(4)}° E'
                                        : place.area,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  onTap: () async {
                                    final resolved = await _placesService.resolveCoordinates(place);
                                    _controller.updateLocation(
                                      address: resolved.fullAddress,
                                      lat: resolved.latitude ?? 27.1025,
                                      lng: resolved.longitude ?? 93.6160,
                                      isConfirmed: true,
                                    );
                                    if (ctx.mounted) {
                                      Navigator.of(ctx).pop();
                                    }
                                  },
                                ),
                              );
                            })
                          else if (!isSearching)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  apiError != null
                                      ? 'Search unavailable: $apiError'
                                      : 'No matching places found.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ),

                          // 5. Saved Addresses Section (if available)
                          if (savedAddresses.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: 10),
                            const Text(
                              'Saved Addresses',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...savedAddresses.take(3).map((addr) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                  leading: const Icon(Icons.bookmark_border, color: AppColors.accent, size: 20),
                                  title: Text(
                                    addr.label,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    addr.formattedAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.secondaryText),
                                  ),
                                  onTap: () {
                                    _controller.updateLocation(
                                      address: addr.formattedAddress,
                                      lat: 27.1025,
                                      lng: 93.6160,
                                      isConfirmed: true,
                                    );
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final draft = _controller.draft;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      GrievanceHeader(
                        title: 'Submit a Grievance',
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      const GrievanceStepProgressIndicator(currentStep: 3),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          InkWell(
                            onTap: _isAcquiringLocation ? null : _detectCurrentLocation,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isAcquiringLocation)
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    const Icon(
                                      Icons.gps_fixed_rounded,
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'GPS Location',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Real Interactive Google Map View (with test/offline fallback)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SmartGoogleMapView(
                      latitude: draft.latitude,
                      longitude: draft.longitude,
                      zoom: 15.0,
                      isInteractive: true,
                      onLocationChanged: (lat, lng) async {
                        // Reverse geocode to keep readable address in sync with marker
                        final address = await _placesService.reverseGeocode(lat, lng);
                        _controller.updateLocation(
                          address: address,
                          lat: lat,
                          lng: lng,
                          isConfirmed: true,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Selected Location & Verification Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.secondarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      const Text(
                                        'Selected Location',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                      // Verified Badge ONLY when user actually confirmed/selected location
                                      if (draft.isLocationConfirmed)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE5F5E9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, size: 10, color: AppColors.success),
                                              SizedBox(width: 3),
                                              Text(
                                                'Verified',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.success,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF4E5),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.touch_app_outlined, size: 10, color: Color(0xFFE89B24)),
                                              SizedBox(width: 3),
                                              Text(
                                                'Pending Selection',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFE89B24),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    draft.locationAddress.isNotEmpty
                                        ? draft.locationAddress
                                        : 'Tap map or use Change Location below',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: draft.locationAddress.isNotEmpty
                                          ? AppColors.primaryText
                                          : AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    draft.isLocationConfirmed
                                        ? 'GPS: ${draft.latitude.toStringAsFixed(4)}° N, ${draft.longitude.toStringAsFixed(4)}° E'
                                        : 'Map Center: ${draft.latitude.toStringAsFixed(4)}° N, ${draft.longitude.toStringAsFixed(4)}° E (Unconfirmed)',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _onChangeLocationModal,
                                child: const Text(
                                  'Change Location',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 2),
                                    content: Text('Viewing coordinates ${draft.latitude.toStringAsFixed(4)}, ${draft.longitude.toStringAsFixed(4)}'),
                                  ),
                                );
                              },
                              child: const Text(
                                'Google Maps View',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Next Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
