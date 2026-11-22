import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../models/grievance_model.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_status_badge.dart';

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
    _loadMapData();
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

            // Interactive Map View
            Expanded(
              child: Stack(
                children: [
                  // Interactive map canvas
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTap: () {
                          // deselect or cycle
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _GisMapPainter(),
                        ),
                      );
                    },
                  ),

                  // Pin Markers from real data
                  if (!_isLoading) ...[
                    // Marker 1 (Center)
                    if (_mapGrievances.isNotEmpty)
                      Positioned(
                        top: 130,
                        left: 140,
                        child: _buildMapPin(
                          _mapGrievances[0],
                          isSelected: _selectedGrievance?.id == _mapGrievances[0].id,
                        ),
                      ),

                    // Marker 2 (Upper right)
                    if (_mapGrievances.length > 1)
                      Positioned(
                        top: 70,
                        right: 80,
                        child: _buildMapPin(
                          _mapGrievances[1],
                          isSelected: _selectedGrievance?.id == _mapGrievances[1].id,
                        ),
                      ),

                    // Marker 3 (Lower left)
                    if (_mapGrievances.length > 2)
                      Positioned(
                        bottom: 90,
                        left: 70,
                        child: _buildMapPin(
                          _mapGrievances[2],
                          isSelected: _selectedGrievance?.id == _mapGrievances[2].id,
                        ),
                      ),
                  ],

                  // Current location GPS button (lower right)
                  Positioned(
                    bottom: 16,
                    right: 20,
                    child: FloatingActionButton.small(
                      heroTag: 'gis_my_location_btn',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 3,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('Centering on your GPS location'),
                          ),
                        );
                      },
                      child: const Icon(Icons.my_location_rounded, size: 20),
                    ),
                  ),
                ],
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

  Widget _buildMapPin(Grievance item, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGrievance = item),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          item.category.icon,
          size: 18,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// Simulated GIS vector map painter with river and road system
class _GisMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background terrain
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAF1ED),
    );

    // River curve
    final riverPaint = Paint()
      ..color = const Color(0xFFBCE0EA)
      ..strokeWidth = 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(size.width * 0.1, 0)
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.2,
        size.height * 0.7,
        size.width * 0.9,
        size.height,
      );
    canvas.drawPath(river, riverPaint);

    // Green parks
    final parkPaint = Paint()..color = const Color(0xFFD4E7DC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 40, size.width * 0.3, size.height * 0.25),
        const Radius.circular(16),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.2, size.width * 0.35, size.height * 0.35),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final roadBorder = Paint()
      ..color = const Color(0xFFD5DFD8)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.45);
    canvas.drawPath(road1, roadBorder);
    canvas.drawPath(road1, roadPaint);

    final road2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(road2, roadBorder);
    canvas.drawPath(road2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
