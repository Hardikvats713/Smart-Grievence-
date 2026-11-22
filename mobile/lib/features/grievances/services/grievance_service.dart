import 'dart:math';
import '../models/grievance_model.dart';

/// Service interface for grievance operations.
abstract class GrievanceService {
  Future<List<Grievance>> getMyGrievances();
  Future<Grievance?> getGrievanceById(String id);
  Future<Grievance> submitGrievance({
    required GrievanceCategory category,
    required String title,
    required String description,
    required String locationAddress,
    double? latitude,
    double? longitude,
    List<String> attachments = const [],
  });
  Future<List<Grievance>> getNearbyGrievances({
    double? latitude,
    double? longitude,
    GrievanceCategory? filterCategory,
  });
  Future<Grievance?> reopenGrievance({
    required String id,
    required String reason,
    required String details,
    List<String> attachments = const [],
  });
  Future<Grievance?> submitFeedback({
    required String id,
    required bool isResolved,
    required int rating,
    String? comments,
  });
}

/// In-memory stub repository conforming to real workflow and data contract.
class StubGrievanceService implements GrievanceService {
  StubGrievanceService() {
    _initSampleData();
  }

  static int _referenceCounter = 1;
  final List<Grievance> _grievances = [];

  void _initSampleData() {
    if (_grievances.isNotEmpty) return;

    _grievances.addAll([
      const Grievance(
        id: 'g-1',
        referenceNumber: 'SG2503180001',
        title: 'Pothole on main road',
        description: 'Large pothole near bus stop causing traffic issues and potential hazard for two wheelers.',
        category: GrievanceCategory.roads,
        status: GrievanceStatus.inProgress,
        locationAddress: 'Main Road, Sector 12, Itanagar',
        latitude: 27.1025,
        longitude: 93.6160,
        attachmentCount: 1,
        attachmentPaths: ['sample_pothole.jpg'],
        submittedDate: '18 Mar 2025',
        lastUpdatedText: 'Updated 2 hours ago',
        distanceText: '250 m away',
        timeline: [
          GrievanceTimelineEvent(
            title: 'Submitted',
            timestamp: '18 Mar 2025, 10:24 AM',
            description: 'Grievance registered and acknowledged by system.',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'Assigned',
            timestamp: '18 Mar 2025, 02:10 PM',
            description: 'Assigned to Public Works Department officer.',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'In Progress',
            timestamp: '19 Mar 2025, 11:30 AM',
            description: 'Work is under process. Material procurement underway.',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'Resolved',
            timestamp: '',
            description: 'Pending resolution verification.',
            isCompleted: false,
          ),
        ],
      ),
      const Grievance(
        id: 'g-2',
        referenceNumber: 'SG2503170005',
        title: 'Streetlight not working',
        description: 'Streetlight outside house number 45 has been dark for three consecutive days.',
        category: GrievanceCategory.electricity,
        status: GrievanceStatus.resolved,
        locationAddress: 'Sector 4, Near Gandhi Park, Itanagar',
        latitude: 27.1050,
        longitude: 93.6210,
        attachmentCount: 0,
        submittedDate: '16 Mar 2025',
        lastUpdatedText: 'Resolved on 16 Mar',
        distanceText: '600 m away',
        timeline: [
          GrievanceTimelineEvent(
            title: 'Submitted',
            timestamp: '15 Mar 2025, 09:15 AM',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'Assigned',
            timestamp: '15 Mar 2025, 11:00 AM',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'Resolved',
            timestamp: '16 Mar 2025, 04:30 PM',
            description: 'Bulb replaced by Electricity Department maintenance crew.',
            isCompleted: true,
          ),
        ],
      ),
      const Grievance(
        id: 'g-3',
        referenceNumber: 'SG2503150009',
        title: 'Garbage not collected',
        description: 'Municipal garbage bin overflowing since weekend. Bad odor and street animals gathering.',
        category: GrievanceCategory.sanitation,
        status: GrievanceStatus.inProgress,
        locationAddress: 'Market Complex, Itanagar',
        latitude: 27.0980,
        longitude: 93.6120,
        attachmentCount: 2,
        submittedDate: '15 Mar 2025',
        lastUpdatedText: 'Updated 1 day ago',
        distanceText: '850 m away',
        timeline: [
          GrievanceTimelineEvent(
            title: 'Submitted',
            timestamp: '15 Mar 2025, 08:00 AM',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'In Progress',
            timestamp: '16 Mar 2025, 10:00 AM',
            description: 'Sanitation vehicle scheduled for dispatch.',
            isCompleted: true,
          ),
        ],
      ),
      const Grievance(
        id: 'g-4',
        referenceNumber: 'SG2503140012',
        title: 'Low water pressure',
        description: 'Water supply pressure is too low to fill storage tank during scheduled morning hours.',
        category: GrievanceCategory.waterSupply,
        status: GrievanceStatus.resolved,
        locationAddress: 'Hill View Colony, Itanagar',
        latitude: 27.1080,
        longitude: 93.6180,
        attachmentCount: 0,
        submittedDate: '14 Mar 2025',
        lastUpdatedText: 'Resolved on 15 Mar',
        distanceText: '1.2 km away',
        timeline: [
          GrievanceTimelineEvent(
            title: 'Submitted',
            timestamp: '14 Mar 2025, 07:30 AM',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'Resolved',
            timestamp: '15 Mar 2025, 02:00 PM',
            description: 'Main pipeline valve regulated to restore normal pressure.',
            isCompleted: true,
          ),
        ],
      ),
      const Grievance(
        id: 'g-5',
        referenceNumber: 'SG2503120003',
        title: 'Damaged drainage cover',
        description: 'Iron drainage grate broken on pedestrian footpath.',
        category: GrievanceCategory.sanitation,
        status: GrievanceStatus.resolved,
        locationAddress: 'College Road, Itanagar',
        latitude: 27.0950,
        longitude: 93.6250,
        attachmentCount: 1,
        submittedDate: '12 Mar 2025',
        lastUpdatedText: 'Resolved on 14 Mar',
        distanceText: '1.5 km away',
        timeline: [
          GrievanceTimelineEvent(
            title: 'Submitted',
            timestamp: '12 Mar 2025, 11:00 AM',
            isCompleted: true,
          ),
          GrievanceTimelineEvent(
            title: 'Resolved',
            timestamp: '14 Mar 2025, 05:00 PM',
            isCompleted: true,
          ),
        ],
      ),
    ]);
  }

  @override
  Future<List<Grievance>> getMyGrievances() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_grievances);
  }

  @override
  Future<Grievance?> getGrievanceById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _grievances.firstWhere(
        (g) => g.id == id || g.referenceNumber == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Grievance> submitGrievance({
    required GrievanceCategory category,
    required String title,
    required String description,
    required String locationAddress,
    double? latitude,
    double? longitude,
    List<String> attachments = const [],
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final countStr = (_referenceCounter++).toString().padLeft(4, '0');
    final refNumber = 'SG250318$countStr';
    final id = 'g-${DateTime.now().millisecondsSinceEpoch}';

    final newGrievance = Grievance(
      id: id,
      referenceNumber: refNumber,
      title: title.trim(),
      description: description.trim(),
      category: category,
      status: GrievanceStatus.submitted,
      locationAddress: locationAddress.trim(),
      latitude: latitude ?? 27.1025 + (Random().nextDouble() * 0.01 - 0.005),
      longitude: longitude ?? 93.6160 + (Random().nextDouble() * 0.01 - 0.005),
      attachmentCount: attachments.length,
      attachmentPaths: attachments,
      submittedDate: 'Just now',
      lastUpdatedText: 'Submitted just now',
      distanceText: 'Nearby',
      timeline: const [
        GrievanceTimelineEvent(
          title: 'Submitted',
          timestamp: 'Just now',
          description: 'Grievance registered and acknowledged by system.',
          isCompleted: true,
        ),
        GrievanceTimelineEvent(
          title: 'Assigned',
          timestamp: '',
          description: 'Pending officer assignment.',
          isCompleted: false,
        ),
        GrievanceTimelineEvent(
          title: 'In Progress',
          timestamp: '',
          description: 'Work pending initiation.',
          isCompleted: false,
        ),
        GrievanceTimelineEvent(
          title: 'Resolved',
          timestamp: '',
          description: 'Pending resolution verification.',
          isCompleted: false,
        ),
      ],
    );

    _grievances.insert(0, newGrievance);
    return newGrievance;
  }

  @override
  Future<List<Grievance>> getNearbyGrievances({
    double? latitude,
    double? longitude,
    GrievanceCategory? filterCategory,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (filterCategory == null) {
      return List.unmodifiable(_grievances);
    }
    return _grievances.where((g) => g.category == filterCategory).toList();
  }

  @override
  Future<Grievance?> reopenGrievance({
    required String id,
    required String reason,
    required String details,
    List<String> attachments = const [],
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _grievances.indexWhere(
      (g) => g.id == id || g.referenceNumber == id,
    );
    if (index == -1) return null;

    final existing = _grievances[index];
    final updatedTimeline = List<GrievanceTimelineEvent>.from(existing.timeline);

    updatedTimeline.add(
      GrievanceTimelineEvent(
        title: 'Reopened',
        timestamp: 'Just now',
        description: 'Citizen reopened grievance: $reason. $details'.trim(),
        isCompleted: true,
      ),
    );

    final updated = existing.copyWith(
      status: GrievanceStatus.inProgress,
      lastUpdatedText: 'Reopened just now',
      timeline: updatedTimeline,
      reopenReason: reason,
      reopenDetails: details,
    );

    _grievances[index] = updated;
    return updated;
  }

  @override
  Future<Grievance?> submitFeedback({
    required String id,
    required bool isResolved,
    required int rating,
    String? comments,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _grievances.indexWhere(
      (g) => g.id == id || g.referenceNumber == id,
    );
    if (index == -1) return null;

    final existing = _grievances[index];
    final updated = existing.copyWith(
      feedbackRating: rating,
      feedbackComments: comments,
      isFeedbackResolved: isResolved,
      lastUpdatedText: 'Feedback submitted',
    );

    _grievances[index] = updated;
    return updated;
  }
}
