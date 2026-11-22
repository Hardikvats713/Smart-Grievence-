import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/app/router.dart';
import 'package:smart_grievance/features/auth/logic/auth_controller.dart';
import 'package:smart_grievance/features/auth/presentation/verify_otp_screen.dart';
import 'package:smart_grievance/features/auth/widgets/resend_otp_control.dart';

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

class _TestAuthController implements AuthController {
  _TestAuthController({
    this.resendCooldown = 3,
    this.verifySuccess = true,
    this.errorMessage,
  });

  final int resendCooldown;
  final bool verifySuccess;
  final String? errorMessage;
  int resendCalls = 0;
  int verifyCalls = 0;
  String? lastVerifiedOtp;

  @override
  int get resendCooldownSeconds => resendCooldown;

  @override
  Future<AuthResult> sendOtp(String phoneNumber) async {
    return const AuthResult(
      status: AuthResultStatus.success,
      message: 'OTP sent',
    );
  }

  @override
  Future<AuthResult> resendOtp(String phoneNumber) async {
    resendCalls++;
    return const AuthResult(
      status: AuthResultStatus.success,
      message: 'New OTP sent',
    );
  }

  @override
  Future<AuthResult> verifyOtp(String phoneNumber, String otp) async {
    verifyCalls++;
    lastVerifiedOtp = otp;
    if (otp == '000000' || !verifySuccess) {
      return AuthResult(
        status: AuthResultStatus.failure,
        message: errorMessage ?? 'Invalid or expired OTP. Please try again.',
      );
    }
    return const AuthResult(
      status: AuthResultStatus.success,
      message: 'Verified',
    );
  }
}

Widget _buildTestApp({
  String phoneNumber = '9876543210',
  AuthController? authController,
}) {
  return DefaultAssetBundle(
    bundle: _ProjectAssetBundle(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VerifyOtpScreen(
        phoneNumber: phoneNumber,
        authController: authController ?? _TestAuthController(),
      ),
      routes: {
        AppRouter.setupProfile: (_) => const Scaffold(
              body: Text('Profile Setup Screen'),
            ),
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phone Number Formatting Helper', () {
    test('formats 10-digit Indian numbers with proper spacing', () {
      expect(formatIndianMobile('9876543210'), equals('+91 98765 43210'));
      expect(formatIndianMobile('8123456789'), equals('+91 81234 56789'));
    });

    test('handles country code prefix gracefully', () {
      expect(formatIndianMobile('+919876543210'), equals('+91 98765 43210'));
      expect(formatIndianMobile('919876543210'), equals('+91 98765 43210'));
    });
  });

  group('VerifyOtpScreen Rendering & Layout', () {
    testWidgets('renders all core UI elements cleanly', (tester) async {
      await tester.pumpWidget(_buildTestApp(phoneNumber: '9876543210'));
      await tester.pump();

      // Heading and formatted number
      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('Enter the 6-digit OTP sent to'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);

      // Back navigation button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // 6 OTP boxes
      expect(find.byType(TextField), findsNWidgets(6));

      // Resend OTP countdown
      expect(find.byType(ResendOtpControl), findsOneWidget);

      // Verify button
      expect(find.widgetWithText(FilledButton, 'Verify'), findsOneWidget);
    });

    testWidgets('Verify button is disabled initially and enabled when 6 digits entered', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final verifyFinder = find.widgetWithText(FilledButton, 'Verify');
      final FilledButton initialButton = tester.widget(verifyFinder);
      expect(initialButton.onPressed, isNull);

      // Enter digits into 5 boxes
      final textFields = find.byType(TextField);
      for (int i = 0; i < 5; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
        await tester.pump();
      }

      final FilledButton fiveDigitButton = tester.widget(verifyFinder);
      expect(fiveDigitButton.onPressed, isNull);

      // Enter 6th digit
      await tester.enterText(textFields.at(5), '6');
      await tester.pump();

      final FilledButton sixDigitButton = tester.widget(verifyFinder);
      expect(sixDigitButton.onPressed, isNotNull);
    });

    testWidgets('pasting 6 digits distributes across all boxes and enables Verify button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final firstBox = find.byType(TextField).first;
      await tester.enterText(firstBox, '839201');
      await tester.pump();

      final textFields = find.byType(TextField);
      expect(tester.widget<TextField>(textFields.at(0)).controller?.text, '8');
      expect(tester.widget<TextField>(textFields.at(1)).controller?.text, '3');
      expect(tester.widget<TextField>(textFields.at(2)).controller?.text, '9');
      expect(tester.widget<TextField>(textFields.at(3)).controller?.text, '2');
      expect(tester.widget<TextField>(textFields.at(4)).controller?.text, '0');
      expect(tester.widget<TextField>(textFields.at(5)).controller?.text, '1');

      final FilledButton button = tester.widget(find.widgetWithText(FilledButton, 'Verify'));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows error message when OTP verification fails', (tester) async {
      final mockAuth = _TestAuthController(
        verifySuccess: false,
        errorMessage: 'Invalid OTP entered',
      );
      await tester.pumpWidget(_buildTestApp(authController: mockAuth));
      await tester.pump();

      // Enter 6 digits
      final firstBox = find.byType(TextField).first;
      await tester.enterText(firstBox, '111111');
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump(); // Enter loading state
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(); // Complete verify

      expect(find.text('Invalid OTP entered'), findsOneWidget);
    });

    testWidgets('successful OTP verification shows confirmation snackbar', (tester) async {
      final mockAuth = _TestAuthController(verifySuccess: true);
      await tester.pumpWidget(_buildTestApp(authController: mockAuth));
      await tester.pump();

      final firstBox = find.byType(TextField).first;
      await tester.enterText(firstBox, '123456');
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('OTP verified successfully!'), findsOneWidget);
      expect(mockAuth.verifyCalls, equals(1));
      expect(mockAuth.lastVerifiedOtp, equals('123456'));
    });

    testWidgets('resend countdown triggers Resend OTP link after cooldown expires', (tester) async {
      final mockAuth = _TestAuthController(resendCooldown: 2);
      await tester.pumpWidget(_buildTestApp(authController: mockAuth));
      await tester.pump();

      expect(find.text('Resend OTP in 00:02'), findsOneWidget);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Resend OTP in 00:01'), findsOneWidget);

      // Advance 1 more second — cooldown expired
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Resend OTP'), findsOneWidget);

      // Tap Resend OTP
      await tester.tap(find.text('Resend OTP'));
      await tester.pump();
      await tester.pump();

      expect(mockAuth.resendCalls, equals(1));
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
        expect(find.byType(VerifyOtpScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (390x844) without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(VerifyOtpScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on large screen (430x932) without overflow', (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(VerifyOtpScreen), findsOneWidget);
      });
    });
  });
}
