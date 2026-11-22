import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/grievance_controller.dart';
import '../models/grievance_model.dart';
import '../widgets/grievance_header.dart';
import '../widgets/grievance_status_badge.dart';

/// Screen 14 — Grievance Details & Timeline.
class GrievanceDetailTimelineScreen extends StatefulWidget {
  const GrievanceDetailTimelineScreen({
    super.key,
    this.grievanceId,
    this.controller,
  });

  final String? grievanceId;
  final GrievanceController? controller;

  @override
  State<GrievanceDetailTimelineScreen> createState() =>
      _GrievanceDetailTimelineScreenState();
}

class _GrievanceDetailTimelineScreenState
    extends State<GrievanceDetailTimelineScreen> {
  late final GrievanceController _controller;
  Grievance? _grievance;
  bool _isLoading = true;
  int _activeTabIndex = 0; // 0: Status Timeline, 1: Details

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GrievanceController.instance;
    _fetchGrievance();
  }

  Future<void> _fetchGrievance() async {
    setState(() => _isLoading = true);
    final id = widget.grievanceId ?? 'g-1';
    final result = await _controller.fetchGrievanceById(id);
    if (mounted) {
      setState(() {
        _grievance = result ??
            // Fallback to sample pothole grievance if not found
            const Grievance(
              id: 'g-1',
              referenceNumber: 'SG2503180001',
              title: 'Pothole on main road',
              description:
                  'Large pothole near bus stop causing traffic issues and potential hazard for two wheelers.',
              category: GrievanceCategory.roads,
              status: GrievanceStatus.inProgress,
              locationAddress: 'Main Road, Sector 12, Itanagar',
              submittedDate: '18 Mar 2025',
              timeline: [
                GrievanceTimelineEvent(
                  title: 'Submitted',
                  timestamp: '18 Mar 2025, 10:24 AM',
                  isCompleted: true,
                ),
                GrievanceTimelineEvent(
                  title: 'Assigned',
                  timestamp: '18 Mar 2025, 02:10 PM',
                  isCompleted: true,
                ),
                GrievanceTimelineEvent(
                  title: 'In Progress',
                  timestamp: '19 Mar 2025, 11:30 AM',
                  description: 'Work is under process.',
                  isCompleted: true,
                ),
                GrievanceTimelineEvent(
                  title: 'Resolved',
                  timestamp: '',
                  isCompleted: false,
                ),
              ],
            );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final item = _grievance!;

    final isResolved = item.status == GrievanceStatus.resolved;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: isResolved
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final res = await Navigator.of(context).pushNamed(
                          '/grievance/reopen',
                          arguments: {
                            'reference': item.referenceNumber,
                            'id': item.id,
                          },
                        );
                        if (res == true) {
                          _fetchGrievance();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reopen',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.of(context).pushNamed(
                          '/grievance/feedback',
                          arguments: {
                            'reference': item.referenceNumber,
                            'id': item.id,
                          },
                        );
                        if (res == true) {
                          _fetchGrievance();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Feedback',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
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
                    title: 'Grievance Details',
                    onBack: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Reference & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item.referenceNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GrievanceStatusBadge(status: item.status),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Grievance Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata: Category, Date, Location
                  Row(
                    children: [
                      Icon(item.category.icon, size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        item.category.displayName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Text(
                        item.submittedDate,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.locationAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Section Tabs: Status Timeline / Details
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EDE8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTabIndex = 0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeTabIndex == 0
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Status Timeline',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: _activeTabIndex == 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _activeTabIndex == 0
                                      ? AppColors.white
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTabIndex = 1),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _activeTabIndex == 1
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: _activeTabIndex == 1
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _activeTabIndex == 1
                                      ? AppColors.white
                                      : AppColors.secondaryText,
                                ),
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
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _activeTabIndex == 0
                    ? _buildTimelineView(item)
                    : _buildDetailsView(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView(Grievance item) {
    final stages = [
      'Submitted',
      'Assigned',
      'In Progress',
      'Resolved',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: stages.asMap().entries.map((entry) {
          final idx = entry.key;
          final stageName = entry.value;
          final isLast = idx == stages.length - 1;

          // Find if there is an event for this stage
          GrievanceTimelineEvent? event;
          try {
            event = item.timeline.firstWhere(
              (e) => e.title.toLowerCase() == stageName.toLowerCase(),
            );
          } catch (_) {
            event = null;
          }

          final bool isResolved = item.status == GrievanceStatus.resolved;
          final bool isCompleted = event?.isCompleted ?? false;
          final bool isCurrent = (stageName == 'In Progress' && !isResolved) ||
              (stageName == 'Resolved' && isResolved);

          Color nodeColor;
          if (isCompleted && !isCurrent) {
            nodeColor = AppColors.success;
          } else if (isCurrent) {
            nodeColor = AppColors.accent;
          } else {
            nodeColor = const Color(0xFFC7D3CD);
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline line & icon
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: nodeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : (isCurrent ? Icons.circle : Icons.radio_button_unchecked),
                        size: 13,
                        color: AppColors.white,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted
                              ? AppColors.success.withValues(alpha: 0.5)
                              : const Color(0xFFD4E0D9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Event details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stageName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppColors.accent
                                : (isCompleted
                                    ? AppColors.primaryText
                                    : AppColors.secondaryText),
                          ),
                        ),
                        if (event != null && event.timestamp.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            event.timestamp,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                        if (event != null && event.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailsView(Grievance item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Full Description',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          const Text(
            'Location Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.locationAddress,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          const Text(
            'Evidence Attachments',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          if (item.attachmentCount > 0)
            Row(
              children: List.generate(
                item.attachmentCount,
                (i) => Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
              ),
            )
          else
            const Text(
              'No attachments provided',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          if (item.feedbackRating != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            const Text(
              'Citizen Feedback',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ...List.generate(
                  5,
                  (star) => Icon(
                    star < item.feedbackRating! ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.feedbackRating} / 5',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            if (item.feedbackComments != null && item.feedbackComments!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.feedbackComments!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ],
          if (item.reopenReason != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            const Text(
              'Reopen History',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reason: ${item.reopenReason}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
            if (item.reopenDetails != null && item.reopenDetails!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.reopenDetails!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
