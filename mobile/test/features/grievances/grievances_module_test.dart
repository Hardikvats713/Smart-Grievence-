import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/app/router.dart';
import 'package:smart_grievance/features/grievances/logic/grievance_controller.dart';
import 'package:smart_grievance/features/grievances/models/grievance_model.dart';
import 'package:smart_grievance/features/grievances/presentation/grievance_detail_timeline_screen.dart';
import 'package:smart_grievance/features/grievances/presentation/grievance_details_screen.dart';
import 'package:smart_grievance/features/grievances/presentation/grievance_location_screen.dart';
import 'package:smart_grievance/features/grievances/presentation/grievance_map_screen.dart';
import 'package:smart_grievance/features/grievances/presentation/my_grievances_screen.dart';
import 'package:smart_grievance/features/grievances/presentation/review_submit_screen.dart';
import 'package:smart_grievance/features/grievances/presentation/select_category_screen.dart';
import 'package:smart_grievance/features/profile/presentation/profile_settings_screen.dart';

Widget _buildTestWrapper({
  required Widget home,
}) {
  final Map<String, WidgetBuilder> routesMap = Map.from(AppRouter.routes);
  routesMap.remove('/'); // avoid conflict with home parameter

  return MaterialApp(
    routes: routesMap,
    home: home,
  );
}

void main() {
  group('Grievance Submission & Tracking Flow Widget Tests', () {
    late GrievanceController controller;

    setUp(() {
      controller = GrievanceController();
    });

    testWidgets('Screen 08: SelectCategoryScreen renders all 7 categories and select',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(home: SelectCategoryScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submit a Grievance'), findsOneWidget);
      expect(find.text('Select Category'), findsOneWidget);
      expect(find.text('Roads'), findsOneWidget);
      expect(find.text('Electricity'), findsOneWidget);
      expect(find.text('Water Supply'), findsOneWidget);
      expect(find.text('Sanitation'), findsOneWidget);

      // Tap on Roads
      await tester.tap(find.text('Roads'));
      await tester.pump();

      expect(controller.draft.category, GrievanceCategory.roads);
    });

    testWidgets('Screen 09: GrievanceDetailsScreen validates required inputs',
        (tester) async {
      controller.selectCategory(GrievanceCategory.roads);

      await tester.pumpWidget(
        _buildTestWrapper(home: GrievanceDetailsScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Grievance Details'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description *'), findsOneWidget);
      expect(find.text('Upload Photos / Videos'), findsOneWidget);

      // Tap Next without filling required fields
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a grievance title'), findsOneWidget);

      // Enter Title and Description
      await tester.enterText(
          find.byType(TextFormField).first, 'Pothole on main road');
      await tester.enterText(
          find.byType(TextFormField).last, 'Large pothole near bus stop');
      await tester.pumpAndSettle();

      // Add evidence photo
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(controller.draft.attachments.length, 1);
    });

    testWidgets('Screen 10: GrievanceLocationScreen renders interactive map & selected address',
        (tester) async {
      controller.selectCategory(GrievanceCategory.roads);
      controller.updateDetails(
        title: 'Pothole on main road',
        description: 'Large pothole near bus stop',
      );

      await tester.pumpWidget(
        _buildTestWrapper(home: GrievanceLocationScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Selected Location'), findsOneWidget);
      expect(find.text('Change Location'), findsOneWidget);
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
    });

    testWidgets('Screen 11 & 12: ReviewSubmitScreen & SubmissionConfirmationScreen',
        (tester) async {
      controller.selectCategory(GrievanceCategory.roads);
      controller.updateDetails(
        title: 'Pothole on main road',
        description: 'Large pothole near bus stop causing traffic issues.',
      );

      await tester.pumpWidget(
        _buildTestWrapper(home: ReviewSubmitScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review & Submit'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Roads'), findsOneWidget);
      expect(find.text('Pothole on main road'), findsOneWidget);

      // Tap Submit
      await tester.tap(find.text('Submit Grievance'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Should arrive at Confirmation
      expect(find.text('Grievance Submitted!'), findsOneWidget);
      expect(find.text('Reference ID'), findsOneWidget);
      expect(find.text('Track My Grievance'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('Screen 13: MyGrievancesScreen loads items and filters by status',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(home: MyGrievancesScreen(controller: controller)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('My Grievances'), findsOneWidget);
      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('In Progress ('), findsOneWidget);
      expect(find.textContaining('Resolved ('), findsOneWidget);
      expect(find.text('Pothole on main road'), findsOneWidget);

      // Tap Resolved filter
      await tester.tap(find.textContaining('Resolved ('));
      await tester.pumpAndSettle();

      expect(find.text('Streetlight not working'), findsOneWidget);
    });

    testWidgets('Screen 14: GrievanceDetailTimelineScreen renders status timeline and details tab',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(
          home: GrievanceDetailTimelineScreen(
            grievanceId: 'g-1',
            controller: controller,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Grievance Details'), findsOneWidget);
      expect(find.text('SG2503180001'), findsOneWidget);
      expect(find.text('Status Timeline'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('In Progress'), findsWidgets);

      // Switch to Details tab
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.text('Full Description'), findsOneWidget);
      expect(find.text('Location Details'), findsOneWidget);
    });

    testWidgets('Screen 15: GrievanceMapScreen renders category chips and nearby issues',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(home: GrievanceMapScreen(controller: controller)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Grievance Map'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Roads'), findsOneWidget);
      expect(find.text('Electricity'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.textContaining('Nearby Issues ('), findsOneWidget);
    });

    testWidgets('Screen 16: ProfileSettingsScreen renders profile card and all rows',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(home: const ProfileSettingsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Tap Logout row to trigger confirmation dialog
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of Smart Grievance?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
