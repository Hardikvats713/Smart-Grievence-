import 'package:flutter/material.dart';

/// Supported grievance categories per storyboard Screen 08.
enum GrievanceCategory {
  roads('Roads', Icons.edit_road_rounded),
  electricity('Electricity', Icons.bolt_rounded),
  waterSupply('Water Supply', Icons.water_drop_outlined),
  sanitation('Sanitation', Icons.delete_outline_rounded),
  education('Education', Icons.school_outlined),
  healthcare('Healthcare', Icons.favorite_border_rounded),
  otherServices('Other Services', Icons.grid_view_rounded);

  const GrievanceCategory(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  static GrievanceCategory? fromDisplayName(String name) {
    for (final cat in values) {
      if (cat.displayName.toLowerCase() == name.toLowerCase()) {
        return cat;
      }
    }
    return null;
  }
}

/// Official Grievance statuses per docs/04_WORKFLOW.md and docs/05_DATA_MODEL.md.
enum GrievanceStatus {
  submitted('Submitted'),
  assigned('Assigned'),
  inProgress('In Progress'),
  resolved('Resolved'),
  underReview('Under Review'),
  resolutionProposed('Resolution Proposed'),
  reopened('Reopened'),
  rejected('Rejected'),
  closed('Closed');

  const GrievanceStatus(this.displayName);

  final String displayName;
}

/// Individual status history entry in the grievance lifecycle.
class GrievanceTimelineEvent {
  const GrievanceTimelineEvent({
    required this.title,
    required this.timestamp,
    this.description,
    this.isCompleted = true,
  });

  final String title;
  final String timestamp;
  final String? description;
  final bool isCompleted;
}

/// Complete Grievance domain entity.
class Grievance {
  const Grievance({
    required this.id,
    required this.referenceNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.locationAddress,
    this.latitude,
    this.longitude,
    this.attachmentCount = 0,
    this.attachmentPaths = const [],
    this.attachmentBytes = const [],
    this.submittedDate = '18 Mar 2025',
    this.lastUpdatedText = 'Updated recently',
    this.timeline = const [],
    this.distanceText,
    this.feedbackRating,
    this.feedbackComments,
    this.isFeedbackResolved,
    this.reopenReason,
    this.reopenDetails,
  });

  final String id;
  final String referenceNumber;
  final String title;
  final String description;
  final GrievanceCategory category;
  final GrievanceStatus status;
  final String locationAddress;
  final double? latitude;
  final double? longitude;
  final int attachmentCount;
  final List<String> attachmentPaths;
  final List<dynamic> attachmentBytes;
  final String submittedDate;
  final String lastUpdatedText;
  final List<GrievanceTimelineEvent> timeline;
  final String? distanceText;
  final int? feedbackRating;
  final String? feedbackComments;
  final bool? isFeedbackResolved;
  final String? reopenReason;
  final String? reopenDetails;

  Grievance copyWith({
    String? id,
    String? referenceNumber,
    String? title,
    String? description,
    GrievanceCategory? category,
    GrievanceStatus? status,
    String? locationAddress,
    double? latitude,
    double? longitude,
    int? attachmentCount,
    List<String>? attachmentPaths,
    List<dynamic>? attachmentBytes,
    String? submittedDate,
    String? lastUpdatedText,
    List<GrievanceTimelineEvent>? timeline,
    String? distanceText,
    int? feedbackRating,
    String? feedbackComments,
    bool? isFeedbackResolved,
    String? reopenReason,
    String? reopenDetails,
  }) {
    return Grievance(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      attachmentBytes: attachmentBytes ?? this.attachmentBytes,
      submittedDate: submittedDate ?? this.submittedDate,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
      timeline: timeline ?? this.timeline,
      distanceText: distanceText ?? this.distanceText,
      feedbackRating: feedbackRating ?? this.feedbackRating,
      feedbackComments: feedbackComments ?? this.feedbackComments,
      isFeedbackResolved: isFeedbackResolved ?? this.isFeedbackResolved,
      reopenReason: reopenReason ?? this.reopenReason,
      reopenDetails: reopenDetails ?? this.reopenDetails,
    );
  }
}
