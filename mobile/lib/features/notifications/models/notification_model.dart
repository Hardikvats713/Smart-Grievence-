import 'package:flutter/material.dart';

enum NotificationType {
  grievanceAssigned('Grievance Assigned', Icons.assignment_ind_outlined),
  statusUpdated('Status Updated', Icons.update_rounded),
  submissionConfirmed('Submission Confirmed', Icons.check_circle_outline_rounded),
  resolutionProposed('Resolution Proposed', Icons.rule_folder_outlined),
  grievanceResolved('Grievance Resolved', Icons.task_alt_rounded),
  grievanceReopened('Grievance Reopened', Icons.replay_rounded);

  const NotificationType(this.displayName, this.icon);

  final String displayName;
  final IconData icon;
}

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.grievanceId,
    this.isRead = false,
    this.dateGroup = 'Today',
  });

  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final String timeAgo;
  final String grievanceId;
  final bool isRead;
  final String dateGroup;

  AppNotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? description,
    String? timeAgo,
    String? grievanceId,
    bool? isRead,
    String? dateGroup,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      grievanceId: grievanceId ?? this.grievanceId,
      isRead: isRead ?? this.isRead,
      dateGroup: dateGroup ?? this.dateGroup,
    );
  }
}
