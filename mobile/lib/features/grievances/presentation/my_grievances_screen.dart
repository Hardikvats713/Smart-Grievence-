import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/widgets/dashboard_bottom_navigation.dart';
import '../logic/grievance_controller.dart';
import '../models/grievance_model.dart';
import '../widgets/grievance_status_badge.dart';

/// Screen 13 — My Grievances List.
class MyGrievancesScreen extends StatefulWidget {
  const MyGrievancesScreen({
    super.key,
    this.controller,
  });

  final GrievanceController? controller;

  @override
  State<MyGrievancesScreen> createState() => _MyGrievancesScreenState();
}

class _MyGrievancesScreenState extends State<MyGrievancesScreen> {
  late final GrievanceController _controller;
  int _selectedFilterIndex = 0; // 0: All, 1: In Progress, 2: Resolved
  List<Grievance> _allGrievances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
    _controller.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await _controller.fetchMyGrievances();
    if (mounted) {
      setState(() {
        _allGrievances = list;
        _isLoading = false;
      });
    }
  }

  List<Grievance> get _filteredList {
    if (_selectedFilterIndex == 1) {
      return _allGrievances
          .where((g) =>
              g.status == GrievanceStatus.inProgress ||
              g.status == GrievanceStatus.assigned ||
              g.status == GrievanceStatus.submitted)
          .toList();
    } else if (_selectedFilterIndex == 2) {
      return _allGrievances
          .where((g) => g.status == GrievanceStatus.resolved)
          .toList();
    }
    return _allGrievances;
  }

  int get _inProgressCount => _allGrievances
      .where((g) =>
          g.status == GrievanceStatus.inProgress ||
          g.status == GrievanceStatus.assigned ||
          g.status == GrievanceStatus.submitted)
      .length;

  int get _resolvedCount => _allGrievances
      .where((g) => g.status == GrievanceStatus.resolved)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'My Grievances',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter Tabs: All, In Progress, Resolved
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          index: 0,
                          label: 'All (${_allGrievances.length})',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          index: 1,
                          label: 'In Progress ($_inProgressCount)',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          index: 2,
                          label: 'Resolved ($_resolvedCount)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Grievance List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No grievances found',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/submit-grievance');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Submit a Grievance',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primary,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            itemCount: _filteredList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _filteredList[index];
                              return _buildGrievanceCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Fixed Bottom Navigation with 'Grievance' tab selected (index: 1)
      bottomNavigationBar: DashboardBottomNavigation(
        selectedIndex: 1,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              // Already on Grievance list
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/grievance-map');
              break;
            case 3:
              Navigator.of(context).pushReplacementNamed('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildFilterChip({required int index, required String label}) {
    final isSelected = _selectedFilterIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

  Widget _buildGrievanceCard(Grievance item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/grievance-details',
            arguments: item.id,
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.referenceNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GrievanceStatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.lastUpdatedText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
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
    );
  }
}
