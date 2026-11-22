import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/app/router.dart';
import 'package:smart_grievance/features/onboarding/models/onboarding_slide.dart';
import 'package:smart_grievance/features/onboarding/presentation/welcome_screen.dart';

class _ProjectAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final candidates = [
      key,
      'mobile/$key',
      'c:/Users/Hardik/Downloads/SMART-GRIEVANCE_READY_TO_START/SMART-GRIEVANCE-READY/mobile/$key',
      'SMART-GRIEVANCE-READY/mobile/$key',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        return ByteData.view(bytes.buffer);
      }
    }
    try {
      return await rootBundle.load(key);
    } catch (_) {
      return ByteData(0);
    }
  }
}

Widget _buildTestApp({
  Widget? home,
  bool autoPlay = false,
  List<OnboardingSlide> slides = OnboardingContent.slides,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home ?? WelcomeScreen(autoPlay: autoPlay, slides: slides),
    routes: {
      AppRouter.authPlaceholder: (_) => const Scaffold(
            body: Text('Auth Placeholder Screen'),
          ),
      AppRouter.welcome: (_) => const WelcomeScreen(autoPlay: false),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WelcomeScreen Carousel Unit & Widget Tests', () {
    testWidgets('renders first slide correctly by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(autoPlay: false));
      await tester.pump();

      // Heading and description for Slide 1
      expect(find.text('Your Voice\nMatters'), findsOneWidget);
      expect(
        find.text('Report civic issues in your community and get them resolved.'),
        findsOneWidget,
      );

      // 3 pagination dots should exist
      final gestureDetectors = find.descendant(
        of: find.byType(Row),
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetectors, findsNWidgets(3));

      // Buttons
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('advances automatically every 3 seconds and loops (1 -> 2 -> 3 -> 1)',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(autoPlay: true));
      await tester.pump();

      // Slide 1
      expect(find.text('Your Voice\nMatters'), findsOneWidget);

      // Advance 3s interval + 450ms animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Easy Complaint\nReporting'), findsOneWidget);

      // Advance another 3s interval + 450ms animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Track Your\nResolution'), findsOneWidget);

      // Advance another 3s interval + 450ms animation -> loops back to Slide 1
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Your Voice\nMatters'), findsOneWidget);

      // Tear down cleanly
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('interactive pagination dots navigate to clicked slide',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(autoPlay: false));
      await tester.pump();

      final dots = find.descendant(
        of: find.byType(Row),
        matching: find.byType(GestureDetector),
      );

      // Tap Dot 2 (Slide 2)
      await tester.tap(dots.at(1));
      await tester.pumpAndSettle();
      expect(find.text('Easy Complaint\nReporting'), findsOneWidget);

      // Tap Dot 3 (Slide 3)
      await tester.tap(dots.at(2));
      await tester.pumpAndSettle();
      expect(find.text('Track Your\nResolution'), findsOneWidget);

      // Tap Dot 1 (Slide 1)
      await tester.tap(dots.at(0));
      await tester.pumpAndSettle();
      expect(find.text('Your Voice\nMatters'), findsOneWidget);
    });

    testWidgets('Get Started button advances slides 1 & 2, then navigates to auth flow on slide 3',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(autoPlay: false));
      await tester.pump();

      final getStartedFinder = find.widgetWithText(FilledButton, 'Get Started');

      // Slide 1 -> tap Get Started
      await tester.tap(getStartedFinder);
      await tester.pumpAndSettle();
      expect(find.text('Easy Complaint\nReporting'), findsOneWidget);

      // Slide 2 -> tap Get Started
      await tester.tap(getStartedFinder);
      await tester.pumpAndSettle();
      expect(find.text('Track Your\nResolution'), findsOneWidget);

      // Slide 3 -> tap Get Started -> Navigates to auth placeholder
      await tester.tap(getStartedFinder);
      await tester.pumpAndSettle();
      expect(find.text('Auth Placeholder Screen'), findsOneWidget);
    });

    testWidgets('Skip button immediately navigates to auth flow from any slide',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(autoPlay: false));
      await tester.pump();

      final skipFinder = find.widgetWithText(TextButton, 'Skip');
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      expect(find.text('Auth Placeholder Screen'), findsOneWidget);
    });

    testWidgets('lifecycle pauses timer in background and resumes on foreground',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(autoPlay: true));
      await tester.pump();

      expect(find.text('Your Voice\nMatters'), findsOneWidget);

      // Simulate app paused (going to background)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 4));
      // Should NOT have advanced because timer was paused
      expect(find.text('Your Voice\nMatters'), findsOneWidget);

      // Simulate app resumed (returning to foreground)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      // Now it advances to Slide 2
      expect(find.text('Easy Complaint\nReporting'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    group('Responsive Screen Layouts', () {
      testWidgets('renders cleanly on small screen (320x568) without overflow',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp(autoPlay: false));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (390x844) without overflow',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp(autoPlay: false));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on large screen (430x932) without overflow',
          (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp(autoPlay: false));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });
    });

    group('Golden Slide Capture for Each Slide', () {
      testWidgets('Slide 1, 2, and 3 golden rendering', (tester) async {
        final bundle = _ProjectAssetBundle();

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late BuildContext savedContext;

        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: bundle,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Builder(
                builder: (context) {
                  savedContext = context;
                  return const WelcomeScreen(autoPlay: false);
                },
              ),
            ),
          ),
        );

        await tester.runAsync(() async {
          await precacheImage(
            const AssetImage('assets/images/onboarding_your_voice.png'),
            savedContext,
          );
          await precacheImage(
            const AssetImage('assets/images/onboarding_easy_reporting.png'),
            savedContext,
          );
          await precacheImage(
            const AssetImage('assets/images/onboarding_city_resolved.png'),
            savedContext,
          );
        });

        // ── Slide 1 Golden ──
        await tester.pump(const Duration(milliseconds: 350));
        await expectLater(
          find.byType(WelcomeScreen),
          matchesGoldenFile('goldens/welcome_slide_1.png'),
        );

        // ── Slide 2 Golden ──
        final dots = find.descendant(
          of: find.byType(Row),
          matching: find.byType(GestureDetector),
        );
        await tester.tap(dots.at(1));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(WelcomeScreen),
          matchesGoldenFile('goldens/welcome_slide_2.png'),
        );

        // ── Slide 3 Golden ──
        await tester.tap(dots.at(2));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(WelcomeScreen),
          matchesGoldenFile('goldens/welcome_slide_3.png'),
        );
      });
    });
  });
}
