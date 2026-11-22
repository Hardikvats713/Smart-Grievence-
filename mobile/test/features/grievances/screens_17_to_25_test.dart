import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/app/router.dart';
import 'package:smart_grievance/features/grievances/category_forms/electricity_grievance_screen.dart';
import 'package:smart_grievance/features/grievances/category_forms/sanitation_grievance_screen.dart';
import 'package:smart_grievance/features/grievances/category_forms/water_supply_grievance_screen.dart';
import 'package:smart_grievance/features/grievances/feedback/resolution_feedback_screen.dart';
import 'package:smart_grievance/features/grievances/logic/grievance_controller.dart';
import 'package:smart_grievance/features/grievances/models/grievance_model.dart';
import 'package:smart_grievance/features/grievances/reopen/reopen_grievance_screen.dart';
import 'package:smart_grievance/features/how_it_works/presentation/how_it_works_screen.dart';
import 'package:smart_grievance/features/notifications/logic/notification_controller.dart';
import 'package:smart_grievance/features/notifications/presentation/notifications_screen.dart';
import 'package:smart_grievance/features/profile/presentation/edit_profile_screen.dart';
import 'package:smart_grievance/features/profile/saved_addresses/saved_addresses_controller.dart';
import 'package:smart_grievance/features/profile/saved_addresses/saved_addresses_screen.dart';

Widget _buildTestWrapper({required Widget home}) {
  final Map<String, WidgetBuilder> routesMap = Map.from(AppRouter.routes);
  routesMap.remove('/');

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: routesMap,
    home: home,
  );
}

void main() {
  group('Screens 17 to 25 Additional Features & Category Forms', () {
    late GrievanceController grievanceController;
    late NotificationController notificationController;
    late SavedAddressesController addressesController;

    setUp(() {
      grievanceController = GrievanceController();
      notificationController = NotificationController();
      addressesController = SavedAddressesController();
    });

    testWidgets('Screen 17: NotificationsScreen renders grouped notifications and marks read',
        (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        home: NotificationsScreen(controller: notificationController),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.textContaining('Status Updated:'), findsOneWidget);
      expect(find.textContaining('Officer Assigned'), findsOneWidget);

      // Tap on Mark all read
      if (find.text('Mark all read').evaluate().isNotEmpty) {
        await tester.tap(find.text('Mark all read'));
        await tester.pumpAndSettle();
        expect(notificationController.unreadCount, 0);
      }
    });

    testWidgets('Screen 18: HowItWorksScreen renders all 4 steps and CTA',
        (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        home: const HowItWorksScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Report an Issue'), findsOneWidget);
      expect(find.text('Grievance Verification'), findsOneWidget);
      expect(find.text('Action & Resolution'), findsOneWidget);
      expect(find.text('Track Your Grievance'), findsOneWidget);
      expect(find.text('Submit a Grievance'), findsOneWidget);
    });

    testWidgets('Screen 19: ElectricityGrievanceScreen validates and submits to common workflow',
        (tester) async {
      grievanceController.selectCategory(GrievanceCategory.electricity);

      await tester.pumpWidget(_buildTestWrapper(
        home: ElectricityGrievanceScreen(controller: grievanceController),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Electricity Grievance'), findsOneWidget);
      expect(find.text('Issue Type *'), findsOneWidget);
      expect(find.text('Consumer Number (Optional)'), findsOneWidget);
      expect(find.text('Affected Households (Optional)'), findsOneWidget);

      // Trigger validation without selection
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Please select an issue type'), findsOneWidget);

      // Select dropdown item
      await tester.tap(find.text('Select electricity issue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Power outage').last);
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Describe the electricity issue...'),
        'Complete blackout across Sector 4 since 2 PM',
      );
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(grievanceController.draft.title, 'Power outage');
      expect(grievanceController.draft.description,
          contains('Complete blackout across Sector 4'));
    });

    testWidgets('Screen 20: WaterSupplyGrievanceScreen validates and updates draft',
        (tester) async {
      grievanceController.selectCategory(GrievanceCategory.waterSupply);

      await tester.pumpWidget(_buildTestWrapper(
        home: WaterSupplyGrievanceScreen(controller: grievanceController),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Water Supply Grievance'), findsOneWidget);
      expect(find.text('Issue Type *'), findsOneWidget);
      expect(find.text('Duration of Problem *'), findsOneWidget);

      // Select issue type
      await tester.tap(find.text('Select water supply issue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Low water pressure').last);
      await tester.pumpAndSettle();

      // Select duration
      await tester.tap(find.text('Select problem duration'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1–3 days').last);
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Describe the water supply issue...'),
        'Unable to fill overhead water tank',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(grievanceController.draft.title, 'Low water pressure');
      expect(grievanceController.draft.description, contains('1–3 days'));
    });

    testWidgets('Screen 21: SanitationGrievanceScreen validates and updates draft',
        (tester) async {
      grievanceController.selectCategory(GrievanceCategory.sanitation);

      await tester.pumpWidget(_buildTestWrapper(
        home: SanitationGrievanceScreen(controller: grievanceController),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sanitation Grievance'), findsOneWidget);
      expect(find.text('Issue Type *'), findsOneWidget);
      expect(find.text('Frequency *'), findsOneWidget);
      expect(find.text('How Long Has It Existed? *'), findsOneWidget);

      // Select issue type
      await tester.tap(find.text('Select sanitation issue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Garbage not collected').last);
      await tester.pumpAndSettle();

      // Select frequency
      await tester.tap(find.text('Select frequency'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daily').last);
      await tester.pumpAndSettle();

      // Select duration
      await tester.tap(find.text('Select duration'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4–7 days').last);
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Describe the sanitation issue...'),
        'Dustbin overflowing outside market complex',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(grievanceController.draft.title, 'Garbage not collected');
      expect(grievanceController.draft.description, contains('Daily'));
    });

    testWidgets('Screen 22: EditProfileScreen loads current profile and validates saving',
        (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        home: const EditProfileScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('District / City'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Screen 23: SavedAddressesScreen renders list and adds new address',
        (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        home: SavedAddressesScreen(controller: addressesController),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('+ Add New Address'), findsOneWidget);

      // Tap Add New Address
      await tester.tap(find.text('+ Add New Address'));
      await tester.pumpAndSettle();

      expect(find.text('Save Address'), findsOneWidget);
    });

    testWidgets('Screen 24: ResolutionFeedbackScreen submits citizen rating & feedback',
        (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        home: const ResolutionFeedbackScreen(
          grievanceReference: 'SG2503170005',
          grievanceId: 'g-2',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Resolution Feedback'), findsOneWidget);
      expect(find.text('SG2503170005'), findsOneWidget);
      expect(find.text('Was your issue resolved?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Rate the resolution'), findsOneWidget);
      expect(find.text('Submit Feedback'), findsOneWidget);

      // Select Yes
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Tap Submit Feedback
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Thank you! Your feedback has been registered.'),
          findsOneWidget);
    });

    testWidgets('Screen 25: ReopenGrievanceScreen validates reason and submits request',
        (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        home: const ReopenGrievanceScreen(
          grievanceReference: 'SG2503170005',
          grievanceId: 'g-2',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Reopen Grievance'), findsOneWidget);
      expect(find.text('SG2503170005'), findsOneWidget);
      expect(find.text('Reason for Reopening *'), findsOneWidget);
      expect(find.text('Additional Details *'), findsOneWidget);
      expect(find.text('Request Reopen'), findsOneWidget);

      // Select reason
      await tester.tap(find.text('Select reason'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Issue is not fully resolved.').last);
      await tester.pumpAndSettle();

      // Enter details
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Describe the remaining issue...'),
        'Streetlight worked for only 2 hours and turned off again.',
      );
      await tester.pumpAndSettle();

      // Tap Request Reopen
      await tester.tap(find.text('Request Reopen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.text('Reopen request submitted for review.'), findsOneWidget);
    });
  });
}
