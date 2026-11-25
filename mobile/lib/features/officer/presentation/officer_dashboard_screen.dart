import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

/// Role-based Officer & Senior Officer Dashboard within the single Flutter app.
/// Displays assigned department queue, SLA alerts, and jurisdiction filters.
class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  bool _isLoading = true;
  String _activeRole = 'DEPARTMENT_OFFICER';
  List<Map<String, dynamic>> _queue = [];
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadOfficerQueue();
  }

  Future<void> _loadOfficerQueue() async {
    setState(() => _isLoading = true);
    final role = await ApiClient.getActiveRole();
    final res = await ApiClient.get('/officer/grievances');

    if (mounted) {
      setState(() {
        _activeRole = role;
        if (res.success && res.data is List) {
          _queue = List<Map<String, dynamic>>.from(res.data as List);
        } else {
          // Graceful offline demo data if backend isn't reachable
          _queue = [
            {
              'id': 'grv-101',
              'reference_number': 'GRV-2026-0101',
              'category': 'Roads',
              'title': 'Deep pothole near Bank Tinali Junction',
              'location_address': 'Bank Tinali, VIP Road, Itanagar',
              'status': 'IN_PROGRESS',
              'priority': 'MEDIUM',
              'slaStatus': 'NORMAL',
              'hoursRemaining': 42,
            },
            {
              'id': 'grv-102',
              'reference_number': 'GRV-2026-0102',
              'category': 'Water Supply',
              'title': 'Broken main water supply pipeline',
              'location_address': 'Market Complex, Sector 12, Itanagar',
              'status': 'SUBMITTED',
              'priority': 'HIGH',
              'slaStatus': 'WARNING',
              'hoursRemaining': 8,
            },
          ];
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredQueue {
    if (_selectedFilter == 'ALL') return _queue;
    return _queue.where((g) {
      final st = (g['status'] ?? '').toString().toUpperCase();
      if (_selectedFilter == 'BREACHED') {
        return g['slaStatus'] == 'BREACHED' || g['slaStatus'] == 'WARNING';
      }
      return st == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = _queue.length;
    final inProgress = _queue.where((g) => g['status'] == 'IN_PROGRESS').length;
    final slaAlert = _queue.where((g) => g['slaStatus'] == 'BREACHED' || g['slaStatus'] == 'WARNING').length;
    final resolved = _queue.where((g) => g['status'] == 'RESOLVED' || g['status'] == 'CLOSED').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeRole == 'SENIOR_OFFICER'
                  ? 'Senior Officer Supervisory Desk'
                  : 'Department Officer Portal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Text(
              'Jurisdiction: Itanagar Capital Complex',
              style: TextStyle(fontSize: 12, color: Color(0xFFDDEEE9)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Queue',
            onPressed: _loadOfficerQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadOfficerQueue,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Metrics Summary Row
                  Row(
                    children: [
                      _MetricCard(label: 'Assigned', value: '$total', color: AppColors.primary),
                      const SizedBox(width: 10),
                      _MetricCard(label: 'In Progress', value: '$inProgress', color: AppColors.information),
                      const SizedBox(width: 10),
                      _MetricCard(label: 'SLA Alert', value: '$slaAlert', color: AppColors.warning),
                      const SizedBox(width: 10),
                      _MetricCard(label: 'Resolved', value: '$resolved', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All ($total)',
                          selected: _selectedFilter == 'ALL',
                          onTap: () => setState(() => _selectedFilter = 'ALL'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Submitted',
                          selected: _selectedFilter == 'SUBMITTED',
                          onTap: () => setState(() => _selectedFilter = 'SUBMITTED'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'In Progress',
                          selected: _selectedFilter == 'IN_PROGRESS',
                          onTap: () => setState(() => _selectedFilter = 'IN_PROGRESS'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'SLA Alert',
                          selected: _selectedFilter == 'BREACHED',
                          onTap: () => setState(() => _selectedFilter = 'BREACHED'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredQueue.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                          SizedBox(height: 12),
                          Text(
                            'No grievances in this filter queue',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredQueue.map((item) => _OfficerGrievanceCard(
                          item: item,
                          onTap: () async {
                            final updated = await Navigator.pushNamed(
                              context,
                              AppRouter.officerGrievanceAction,
                              arguments: item,
                            );
                            if (updated == true) {
                              _loadOfficerQueue();
                            }
                          },
                        )),
                ],
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}

class _OfficerGrievanceCard extends StatelessWidget {
  const _OfficerGrievanceCard({required this.item, required this.onTap});
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ref = item['reference_number']?.toString() ?? 'GRV-2026';
    final title = item['title']?.toString() ?? 'Civic Grievance';
    final category = item['category']?.toString() ?? 'General';
    final address = item['location_address']?.toString() ?? 'Itanagar';
    final status = item['status']?.toString() ?? 'SUBMITTED';
    final slaStatus = item['slaStatus']?.toString() ?? 'NORMAL';

    final Color slaColor = slaStatus == 'BREACHED'
        ? AppColors.error
        : slaStatus == 'WARNING'
            ? AppColors.warning
            : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: slaColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SLA: $slaStatus',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: slaColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(category, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.secondarySurface,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    status.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
