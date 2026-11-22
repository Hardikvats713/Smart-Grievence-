import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/auth/logic/auth_controller.dart';
import 'package:smart_grievance/features/grievances/logic/grievance_controller.dart';
import 'package:smart_grievance/features/grievances/models/grievance_model.dart';
import 'package:smart_grievance/features/home/logic/dashboard_controller.dart';
import 'package:smart_grievance/features/notifications/logic/notification_controller.dart';
import 'package:smart_grievance/features/notifications/models/notification_model.dart';
import 'package:smart_grievance/features/profile/logic/profile_controller.dart';
import 'package:smart_grievance/features/profile/saved_addresses/saved_addresses_controller.dart';

void main() {
  group('End-to-End Backend Logic & Civic Workflow Integration Tests', () {
    late StubAuthController authController;
    late StubProfileController profileController;
    late GrievanceController grievanceController;
    late NotificationController notificationController;
    late SavedAddressesController addressesController;
    late DashboardController dashboardController;

    setUp(() {
      authController = StubAuthController();
      profileController = StubProfileController.instance;
      notificationController = NotificationController.instance;
      addressesController = SavedAddressesController.instance;
      grievanceController = GrievanceController.instance;
      dashboardController = DashboardController();
    });

    test('1. Citizen Authentication & Dynamic Profile Lifecycle', () async {
      // Step A: Send OTP
      final sendResult = await authController.sendOtp('9876543210');
      expect(sendResult.isSuccess, isTrue);

      // Step B: Verify OTP
      final verifyResult = await authController.verifyOtp('9876543210', '146284');
      expect(verifyResult.isSuccess, isTrue);

      // Step C: Save user profile
      const testProfile = UserProfile(
        fullName: 'Hardik Sharma',
        email: 'hardik.sharma@civic.in',
        district: 'Papum Pare',
        phoneNumber: '9876543210',
      );
      final saveResult = await profileController.saveProfile(testProfile);
      expect(saveResult.isSuccess, isTrue);
      expect(profileController.currentProfile?.fullName, 'Hardik Sharma');

      // Step D: Verify dashboard reflects the updated citizen name
      await dashboardController.loadDashboardData();
      expect(dashboardController.state.citizenName, 'Hardik Sharma');
    });

    test('2. Grievance Submission & Live Notification Generation', () async {
      final initialNotificationCount = notificationController.unreadCount;

      // Step A: Draft grievance
      grievanceController.resetDraft();
      grievanceController.selectCategory(GrievanceCategory.electricity);
      grievanceController.updateDetails(
        title: 'Transformer sparking near school',
        description: 'Exposed wiring and loud sparking on transformer unit [Consumer No: ELEC-9921]',
      );
      grievanceController.updateLocation(
        address: 'Sector 4, Main Market, Itanagar',
        lat: 27.1040,
        lng: 93.6190,
      );
      grievanceController.addAttachment('evidence_transformer.jpg');

      expect(grievanceController.draft.isComplete, isTrue);

      // Step B: Submit grievance
      final submittedGrievance = await grievanceController.submit();
      expect(submittedGrievance, isNotNull);
      expect(submittedGrievance!.title, 'Transformer sparking near school');
      expect(submittedGrievance.category, GrievanceCategory.electricity);
      expect(submittedGrievance.status, GrievanceStatus.submitted);
      expect(submittedGrievance.referenceNumber, startsWith('SG'));
      expect(submittedGrievance.attachmentCount, 1);

      // Step C: Verify notification was automatically generated
      expect(notificationController.unreadCount, initialNotificationCount + 1);
      final latestNotification = notificationController.notifications.first;
      expect(latestNotification.type, NotificationType.submissionConfirmed);
      expect(latestNotification.title, contains(submittedGrievance.referenceNumber));
      expect(latestNotification.grievanceId, submittedGrievance.id);

      // Step D: Verify new grievance is present in citizen list and GIS map
      final myList = await grievanceController.fetchMyGrievances();
      expect(myList.any((g) => g.id == submittedGrievance.id), isTrue);

      final mapList = await grievanceController.fetchNearbyGrievances(
        filter: GrievanceCategory.electricity,
      );
      expect(mapList.any((g) => g.id == submittedGrievance.id), isTrue);
    });

    test('3. Category-Specific Grievance Forms Data Integrity', () async {
      // Test Water Supply specialized form fields accumulation
      grievanceController.resetDraft();
      grievanceController.selectCategory(GrievanceCategory.waterSupply);
      grievanceController.updateDetails(
        title: 'Pipeline leakage',
        description: 'Underground main line burst near intersection [Water Conn No: WTR-4412] [Duration: 1–3 days]',
      );
      grievanceController.updateLocation(
        address: 'Hill View Colony, Itanagar',
        lat: 27.1080,
        lng: 93.6180,
      );

      final waterGrievance = await grievanceController.submit();
      expect(waterGrievance, isNotNull);
      expect(waterGrievance!.category, GrievanceCategory.waterSupply);
      expect(waterGrievance.description, contains('WTR-4412'));
      expect(waterGrievance.description, contains('1–3 days'));

      // Test Sanitation specialized form fields accumulation
      grievanceController.resetDraft();
      grievanceController.selectCategory(GrievanceCategory.sanitation);
      grievanceController.updateDetails(
        title: 'Overflowing dustbin',
        description: 'Community garbage container overflowing [Frequency: Daily] [Duration: 4–7 days]',
      );
      grievanceController.updateLocation(
        address: 'Market Complex, Itanagar',
        lat: 27.0980,
        lng: 93.6120,
      );

      final sanitGrievance = await grievanceController.submit();
      expect(sanitGrievance, isNotNull);
      expect(sanitGrievance!.category, GrievanceCategory.sanitation);
      expect(sanitGrievance.description, contains('Daily'));
      expect(sanitGrievance.description, contains('4–7 days'));
    });

    test('4. Resolution Feedback Submission & State Persistence', () async {
      // Target existing resolved grievance g-2
      final grievance = await grievanceController.fetchGrievanceById('g-2');
      expect(grievance, isNotNull);
      expect(grievance!.status, GrievanceStatus.resolved);

      // Submit 5-star feedback
      final feedbackResult = await grievanceController.submitFeedback(
        id: 'g-2',
        isResolved: true,
        rating: 5,
        comments: 'Repaired quickly by maintenance team. Very satisfied!',
      );

      expect(feedbackResult, isNotNull);
      expect(feedbackResult!.feedbackRating, 5);
      expect(feedbackResult.isFeedbackResolved, isTrue);
      expect(feedbackResult.feedbackComments, contains('Very satisfied!'));

      // Re-fetch to confirm persistence in service
      final updated = await grievanceController.fetchGrievanceById('g-2');
      expect(updated?.feedbackRating, 5);
      expect(updated?.isFeedbackResolved, isTrue);
    });

    test('5. Reopen Grievance Workflow, Timeline Progression & Notifications', () async {
      // Target existing resolved grievance g-4
      final grievance = await grievanceController.fetchGrievanceById('g-4');
      expect(grievance, isNotNull);
      expect(grievance!.status, GrievanceStatus.resolved);

      // Reopen grievance
      final reopened = await grievanceController.reopenGrievance(
        id: 'g-4',
        reason: 'The issue has occurred again.',
        details: 'Low pressure resumed this morning. Storage tank still empty.',
        attachments: ['reopen_gauge_photo.jpg'],
      );

      expect(reopened, isNotNull);
      expect(reopened!.status, GrievanceStatus.inProgress);
      expect(reopened.reopenReason, 'The issue has occurred again.');
      expect(reopened.reopenDetails, contains('Low pressure resumed'));

      // Timeline must contain 'Reopened' event
      expect(reopened.timeline.any((e) => e.title == 'Reopened'), isTrue);
      final reopenEvent = reopened.timeline.firstWhere((e) => e.title == 'Reopened');
      expect(reopenEvent.isCompleted, isTrue);
      expect(reopenEvent.description, contains('The issue has occurred again.'));

      // Check notification generated
      final latestNotification = notificationController.notifications.first;
      expect(latestNotification.type, NotificationType.grievanceReopened);
      expect(latestNotification.title, contains(reopened.referenceNumber));
    });

    test('6. Saved Addresses Operations and Retrieval', () {
      final initialCount = addressesController.addresses.length;

      // Add address
      const newAddress = SavedAddressItem(
        id: 'addr-test-custom',
        label: 'Community Hall',
        houseBuilding: 'Plot 88',
        streetLocality: 'Sector 6, Ring Road',
        districtCity: 'Itanagar',
        state: 'Arunachal Pradesh',
        postalCode: '791114',
      );
      addressesController.addAddress(newAddress);
      expect(addressesController.addresses.length, initialCount + 1);
      expect(addressesController.addresses.any((a) => a.id == 'addr-test-custom'), isTrue);

      // Delete address
      addressesController.deleteAddress('addr-test-custom');
      expect(addressesController.addresses.length, initialCount);
    });

    test('7. Notification Center Mark as Read & Badge Sync', () {
      final initialUnread = notificationController.unreadCount;
      expect(initialUnread, greaterThan(0));

      // Mark single notification read
      final unreadItem = notificationController.notifications.firstWhere((n) => !n.isRead);
      notificationController.markAsRead(unreadItem.id);
      expect(notificationController.unreadCount, initialUnread - 1);

      // Mark all read
      notificationController.markAllAsRead();
      expect(notificationController.unreadCount, 0);
    });
  });
}
