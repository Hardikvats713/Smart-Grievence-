import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/app/router.dart';
import 'package:smart_grievance/core/theme/app_colors.dart';
import 'package:smart_grievance/features/splash/logic/splash_controller.dart';
import 'package:smart_grievance/features/splash/presentation/splash_screen.dart';

/// Test controller that lets us control when initialization completes.
class _DelayedSplashController extends SplashController {
  final Completer<void> _completer = Completer<void>();

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> initialize() => _completer.future;
}

Widget _buildTestApp(Widget home) {
  return MaterialApp(
    home: home,
    routes: {
      AppRouter.welcome: (_) => const Scaffold(body: Text('Welcome Screen')),
    },
  );
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders with Warm Ivory background', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AppColors.background);

      controller.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('displays logo image', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('smart_grievance_logo'),
      );
      expect(imageFinder, findsOneWidget);

      controller.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('displays cityscape illustration', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('splash_cityscape'),
      );
      expect(imageFinder, findsOneWidget);

      controller.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows loading indicator during init', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      controller.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('loading indicator uses Deep Teal Green color', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, AppColors.primary);

      controller.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('navigates away after init completes', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const SplashScreen()),
      );

      await tester.pumpAndSettle();

      // After initialization completes, navigates to the placeholder for Welcome Screen
      expect(find.textContaining('Welcome Screen'), findsOneWidget);
    });

    testWidgets('logo has accessibility semantics', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      final semantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Smart Grievance logo',
      );
      expect(semantics, findsOneWidget);

      controller.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('cityscape has accessibility semantics', (tester) async {
      final controller = _DelayedSplashController();
      await tester.pumpWidget(
        _buildTestApp(SplashScreen(controller: controller)),
      );

      final semantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Cityscape illustration'),
      );
      expect(semantics, findsOneWidget);

      controller.complete();
      await tester.pumpAndSettle();
    });

    group('Responsive layouts', () {
      testWidgets('adapts to small screen (320x568) without overflow',
          (tester) async {
        final controller = _DelayedSplashController();
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _buildTestApp(SplashScreen(controller: controller)),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.byType(SplashScreen), findsOneWidget);

        controller.complete();
        await tester.pumpAndSettle();
      });

      testWidgets('adapts to standard screen (390x844) without overflow',
          (tester) async {
        final controller = _DelayedSplashController();
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _buildTestApp(SplashScreen(controller: controller)),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.byType(SplashScreen), findsOneWidget);

        controller.complete();
        await tester.pumpAndSettle();
      });

      testWidgets('adapts to large screen (430x932) without overflow',
          (tester) async {
        final controller = _DelayedSplashController();
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _buildTestApp(SplashScreen(controller: controller)),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.byType(SplashScreen), findsOneWidget);

        controller.complete();
        await tester.pumpAndSettle();
      });
    });
  });
}
