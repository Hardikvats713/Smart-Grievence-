import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../models/grievance_model.dart';
import 'live_map_view.dart';

/// Real Google Map widget for Android/iOS/Web, with seamless fallback to
/// high-fidelity cartography for widget tests and offline environments.
class SmartGoogleMapView extends StatefulWidget {
  const SmartGoogleMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15.0,
    this.isInteractive = true,
    this.onLocationChanged,
    this.grievances = const [],
    this.selectedGrievance,
    this.onGrievanceSelected,
    this.onMapCreated,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final bool isInteractive;
  final void Function(double lat, double lng)? onLocationChanged;
  final List<Grievance> grievances;
  final Grievance? selectedGrievance;
  final ValueChanged<Grievance>? onGrievanceSelected;
  final void Function(GoogleMapController controller)? onMapCreated;

  @override
  State<SmartGoogleMapView> createState() => _SmartGoogleMapViewState();
}

class _SmartGoogleMapViewState extends State<SmartGoogleMapView> {
  GoogleMapController? _mapController;
  late double _currentLat;
  late double _currentLng;
  late double _currentZoom;

  bool get _shouldUseFallback {
    if (kIsWeb) return false;
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return true;
      }
      return defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS;
    } catch (_) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentLat = widget.latitude;
    _currentLng = widget.longitude;
    _currentZoom = widget.zoom;
  }

  @override
  void didUpdateWidget(covariant SmartGoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _currentLat = widget.latitude;
      _currentLng = widget.longitude;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLat, _currentLng),
        ),
      );
    }
  }

  Set<Marker> _buildGoogleMarkers() {
    final markers = <Marker>{};

    if (widget.grievances.isNotEmpty) {
      for (final g in widget.grievances) {
        final lat = g.latitude ?? 27.1025;
        final lng = g.longitude ?? 93.6160;
        final isSelected = widget.selectedGrievance?.id == g.id;

        markers.add(
          Marker(
            markerId: MarkerId(g.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: g.title,
              snippet: '${g.referenceNumber} • ${g.category.displayName}',
              onTap: () => widget.onGrievanceSelected?.call(g),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected
                  ? BitmapDescriptor.hueAzure
                  : g.status == GrievanceStatus.resolved
                      ? BitmapDescriptor.hueGreen
                      : BitmapDescriptor.hueOrange,
            ),
            onTap: () => widget.onGrievanceSelected?.call(g),
          ),
        );
      }
    } else {
      // Single marker for grievance location picking
      markers.add(
        Marker(
          markerId: const MarkerId('selected_grievance_location'),
          position: LatLng(_currentLat, _currentLng),
          draggable: widget.isInteractive,
          infoWindow: const InfoWindow(
            title: 'Selected Grievance Location',
            snippet: 'Drag or tap map to update',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onDragEnd: (newPos) {
            setState(() {
              _currentLat = newPos.latitude;
              _currentLng = newPos.longitude;
            });
            widget.onLocationChanged?.call(newPos.latitude, newPos.longitude);
          },
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldUseFallback) {
      return LiveMapView(
        latitude: widget.latitude,
        longitude: widget.longitude,
        zoom: widget.zoom,
        isInteractive: widget.isInteractive,
        onLocationChanged: widget.onLocationChanged,
        grievances: widget.grievances,
        selectedGrievance: widget.selectedGrievance,
        onGrievanceSelected: widget.onGrievanceSelected,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLat, _currentLng),
                zoom: _currentZoom,
              ),
              markers: _buildGoogleMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                widget.onMapCreated?.call(controller);
              },
              onTap: widget.isInteractive && widget.grievances.isEmpty
                  ? (pos) {
                      setState(() {
                        _currentLat = pos.latitude;
                        _currentLng = pos.longitude;
                      });
                      widget.onLocationChanged?.call(pos.latitude, pos.longitude);
                    }
                  : null,
              onCameraMove: (pos) {
                _currentZoom = pos.zoom;
              },
            ),

            // Map Controls Overlay (Zoom In, Zoom Out, Recenter)
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'gmap_zoom_in_${identityHashCode(this)}',
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 3,
                    onPressed: () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                    child: const Icon(Icons.add, size: 20),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'gmap_zoom_out_${identityHashCode(this)}',
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 3,
                    onPressed: () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                    child: const Icon(Icons.remove, size: 20),
                  ),
                  const SizedBox(height: 6),
                  FloatingActionButton.small(
                    heroTag: 'gmap_recenter_${identityHashCode(this)}',
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 3,
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(widget.latitude, widget.longitude),
                          widget.zoom,
                        ),
                      );
                    },
                    child: const Icon(Icons.my_location_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
