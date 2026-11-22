import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/auth/logic/auth_controller.dart';
import 'package:smart_grievance/app/router.dart';
import 'package:smart_grievance/features/auth/presentation/get_started_screen.dart';
import 'package:smart_grievance/features/auth/widgets/mobile_number_field.dart';

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

Widget _buildTestApp({Widget? home}) {
  return DefaultAssetBundle(
    bundle: _ProjectAssetBundle(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home ?? const GetStartedScreen(),
      routes: {
        AppRouter.verifyOtp: (_) => const Scaffold(
              body: Text('Verify OTP Screen'),
            ),
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile Number Validation Logic', () {
    test('rejects empty input', () {
      expect(validateIndianMobile(''), equals('Please enter your mobile number'));
      expect(validateIndianMobile('   '), equals('Please enter your mobile number'));
    });

    test('rejects numbers with length other than 10', () {
      expect(validateIndianMobile('98765'), equals('Enter a valid 10-digit mobile number'));
      expect(validateIndianMobile('987654321'), equals('Enter a valid 10-digit mobile number'));
      expect(validateIndianMobile('98765432101'), equals('Enter a valid 10-digit mobile number'));
    });

    test('rejects numbers not starting with 6, 7, 8, or 9', () {
      expect(validateIndianMobile('1234567890'), equals('Enter a valid Indian mobile number'));
      expect(validateIndianMobile('5555555555'), equals('Enter a valid Indian mobile number'));
      expect(validateIndianMobile('0987654321'), equals('Enter a valid Indian mobile number'));
    });

    test('accepts valid 10-digit Indian mobile numbers', () {
      expect(validateIndianMobile('9876543210'), isNull);
      expect(validateIndianMobile('8123456789'), isNull);
      expect(validateIndianMobile('7012345678'), isNull);
      expect(validateIndianMobile('6398765432'), isNull);
    });
  });

  group('GetStartedScreen Rendering & Interactions', () {
    testWidgets('renders all core UI elements cleanly', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      // Heading and description
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Enter your mobile number to continue'), findsOneWidget);

      // Flag, country code and mobile field
      expect(find.byType(IndiaFlagIcon), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Send OTP button
      expect(find.widgetWithText(FilledButton, 'Send OTP'), findsOneWidget);

      // Registration prompt
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('input field restricts characters to 10 digits only', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'abcd987654321099xyz');
      await tester.pump();

      // Digits only and limited to 10 characters: '9876543210'
      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.controller?.text, equals('9876543210'));
    });

    testWidgets('tapping Send OTP with empty or invalid input displays validation errors', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final buttonFinder = find.widgetWithText(FilledButton, 'Send OTP');

      // 1. Tap with empty input
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(find.text('Please enter your mobile number'), findsOneWidget);

      // 2. Enter incomplete number
      await tester.enterText(find.byType(TextField), '98765');
      await tester.pump();
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);

      // 3. Enter 10 digits starting with invalid digit (e.g. 1)
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump();
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(find.text('Enter a valid Indian mobile number'), findsOneWidget);
    });

    testWidgets('tapping Send OTP sends OTP and shows confirmation snackbar', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pump();

      final buttonFinder = find.widgetWithText(FilledButton, 'Send OTP');
      await tester.tap(buttonFinder);
      await tester.pump(); // Enter loading state

      // Shows loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance through simulated network call
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump();

      expect(find.text('OTP sent to +91 9876543210'), findsOneWidget);
    });

    testWidgets('tapping Register triggers informational feedback', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final registerFinder = find.text('Register');
      await tester.tap(registerFinder);
      await tester.pump();

      expect(find.text('Registration screen coming soon.'), findsOneWidget);
    });

    group('Responsive Screen Layouts', () {
      testWidgets('renders cleanly on small screen (320x568) without overflow', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(GetStartedScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (390x844) without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(GetStartedScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on large screen (430x932) without overflow', (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(GetStartedScreen), findsOneWidget);
      });
    });
  });
}
