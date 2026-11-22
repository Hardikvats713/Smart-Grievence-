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
import 'package:smart_grievance/features/notifications/presentation/notifications_screen.dart';
import 'package:smart_grievance/features/profile/presentation/edit_profile_screen.dart';
import 'package:smart_grievance/features/profile/saved_addresses/saved_addresses_screen.dart';

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

  testWidgets('Screen 17 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const NotificationsScreen()));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(NotificationsScreen), matchesGoldenFile('goldens/screen_17_notifications.png'));
  });

  testWidgets('Screen 18 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const HowItWorksScreen()));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(HowItWorksScreen), matchesGoldenFile('goldens/screen_18_how_it_works.png'));
  });

  testWidgets('Screen 19 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    controller.selectCategory(GrievanceCategory.electricity);

    await tester.pumpWidget(
        _buildFramedScreen(ElectricityGrievanceScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ElectricityGrievanceScreen),
        matchesGoldenFile('goldens/screen_19_electricity_form.png'));
  });

  testWidgets('Screen 20 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    controller.selectCategory(GrievanceCategory.waterSupply);

    await tester.pumpWidget(
        _buildFramedScreen(WaterSupplyGrievanceScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(WaterSupplyGrievanceScreen),
        matchesGoldenFile('goldens/screen_20_water_supply_form.png'));
  });

  testWidgets('Screen 21 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = GrievanceController();
    controller.selectCategory(GrievanceCategory.sanitation);

    await tester.pumpWidget(
        _buildFramedScreen(SanitationGrievanceScreen(controller: controller)));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SanitationGrievanceScreen),
        matchesGoldenFile('goldens/screen_21_sanitation_form.png'));
  });

  testWidgets('Screen 22 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const EditProfileScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(EditProfileScreen),
        matchesGoldenFile('goldens/screen_22_edit_profile.png'));
  });

  testWidgets('Screen 23 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const SavedAddressesScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SavedAddressesScreen),
        matchesGoldenFile('goldens/screen_23_saved_addresses.png'));
  });

  testWidgets('Screen 24 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const ResolutionFeedbackScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ResolutionFeedbackScreen),
        matchesGoldenFile('goldens/screen_24_resolution_feedback.png'));
  });

  testWidgets('Screen 25 Golden', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildFramedScreen(const ReopenGrievanceScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ReopenGrievanceScreen),
        matchesGoldenFile('goldens/screen_25_reopen_grievance.png'));
  });
}
