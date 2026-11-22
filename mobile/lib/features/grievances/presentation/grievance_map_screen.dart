import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../models/grievance_model.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_status_badge.dart';
import '../widgets/smart_google_map_view.dart';

/// Screen 15 — Grievance Map (GIS).
class GrievanceMapScreen extends StatefulWidget {
  const GrievanceMapScreen({
    super.key,
    this.controller,
  });

  final GrievanceController? controller;

  @override
  State<GrievanceMapScreen> createState() => _GrievanceMapScreenState();
}

class _GrievanceMapScreenState extends State<GrievanceMapScreen> {
  late final GrievanceController _controller;
  String _selectedCategoryKey = 'All'; // 'All', 'Roads', 'Electricity', 'Water'
  List<Grievance> _mapGrievances = [];
  Grievance? _selectedGrievance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
    _controller.addListener(_loadMapData);
    _loadMapData();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMapData);
    super.dispose();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    GrievanceCategory? filter;
    if (_selectedCategoryKey == 'Roads') filter = GrievanceCategory.roads;
    if (_selectedCategoryKey == 'Electricity') filter = GrievanceCategory.electricity;
    if (_selectedCategoryKey == 'Water') filter = GrievanceCategory.waterSupply;

    final list = await _controller.fetchNearbyGrievances(filter: filter);
    if (mounted) {
      setState(() {
        _mapGrievances = list;
        _selectedGrievance = list.isNotEmpty ? list.first : null;
        _isLoading = false;
      });
    }
  }

  void _onFilterTap(String key) {
    if (_selectedCategoryKey == key) return;
    setState(() {
      _selectedCategoryKey = key;
    });
    _loadMapData();
  }

  @override
  Widget build(BuildContext context) {
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
                    title: 'Grievance Map',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 8),

                  // Category Filter Chips: All, Roads, Electricity, Water
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Roads'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Electricity'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Water'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Interactive Live Slippy Map View
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : SmartGoogleMapView(
                      latitude: _selectedGrievance?.latitude ?? 27.1025,
                      longitude: _selectedGrievance?.longitude ?? 93.6160,
                      zoom: 14.5,
                      isInteractive: true,
                      grievances: _mapGrievances,
                      selectedGrievance: _selectedGrievance,
                      onGrievanceSelected: (g) {
                        setState(() => _selectedGrievance = g);
                      },
                      onLocationChanged: (lat, lng) {},
                    ),
            ),

            // Nearby Issues Bottom Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nearby Issues (${_mapGrievances.length})',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedGrievance != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/grievance-details',
                            arguments: _selectedGrievance!.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedGrievance!.title,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        GrievanceStatusBadge(
                                          status: _selectedGrievance!.status,
                                        ),
                                        if (_selectedGrievance!.distanceText != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            _selectedGrievance!.distanceText!,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.secondaryText,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategoryKey == label;

    return GestureDetector(
      onTap: () => _onFilterTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
