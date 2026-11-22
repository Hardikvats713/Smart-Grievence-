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
import 'package:smart_grievance/features/grievances/presentation/submission_confirmation_screen.dart';
import 'package:smart_grievance/features/profile/presentation/profile_settings_screen.dart';

Widget _buildFramedScreen(Widget screen) {
  final Map<String, WidgetBuilder> routesMap = Map.from(AppRouter.routes);
  routesMap.remove('/');

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: routesMap,
    home: screen,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Screen 08 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    await tester.pumpWidget(_buildFramedScreen(SelectCategoryScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SelectCategoryScreen), matchesGoldenFile('goldens/screen_08_select_category.png'));
  });

  testWidgets('Screen 09 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    controller.selectCategory(GrievanceCategory.roads);
    controller.updateDetails(
      title: 'Pothole on main road',
      description: 'Large pothole near bus stop causing traffic issues.',
    );
    controller.addAttachment('sample_evidence.jpg');

    await tester.pumpWidget(_buildFramedScreen(GrievanceDetailsScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(GrievanceDetailsScreen), matchesGoldenFile('goldens/screen_09_grievance_details.png'));
  });

  testWidgets('Screen 10 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    await tester.pumpWidget(_buildFramedScreen(GrievanceLocationScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(GrievanceLocationScreen), matchesGoldenFile('goldens/screen_10_grievance_location.png'));
  });

  testWidgets('Screen 11 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    controller.selectCategory(GrievanceCategory.roads);
    controller.updateDetails(
      title: 'Pothole on main road',
      description: 'Large pothole near bus stop causing traffic issues.',
    );
    controller.addAttachment('sample_evidence.jpg');

    await tester.pumpWidget(_buildFramedScreen(ReviewSubmitScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ReviewSubmitScreen), matchesGoldenFile('goldens/screen_11_review_submit.png'));
  });

  testWidgets('Screen 12 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    await tester.pumpWidget(_buildFramedScreen(SubmissionConfirmationScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SubmissionConfirmationScreen), matchesGoldenFile('goldens/screen_12_submission_confirmation.png'));
  });

  testWidgets('Screen 13 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    await tester.pumpWidget(_buildFramedScreen(MyGrievancesScreen(controller: controller)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MyGrievancesScreen), matchesGoldenFile('goldens/screen_13_my_grievances.png'));
  });

  testWidgets('Screen 14 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    await tester.pumpWidget(_buildFramedScreen(GrievanceDetailTimelineScreen(grievanceId: 'g-1', controller: controller)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    await expectLater(find.byType(GrievanceDetailTimelineScreen), matchesGoldenFile('goldens/screen_14_grievance_details_timeline.png'));
  });

  testWidgets('Screen 15 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    await tester.pumpWidget(_buildFramedScreen(GrievanceMapScreen(controller: controller)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await expectLater(find.byType(GrievanceMapScreen), matchesGoldenFile('goldens/screen_15_grievance_map.png'));
  });

  testWidgets('Screen 16 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const ProfileSettingsScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ProfileSettingsScreen), matchesGoldenFile('goldens/screen_16_profile_settings.png'));
  });
}
