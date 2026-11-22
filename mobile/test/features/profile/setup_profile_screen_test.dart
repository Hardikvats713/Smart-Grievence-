import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/profile/logic/district_provider.dart';
import 'package:smart_grievance/features/profile/logic/photo_picker_service.dart';
import 'package:smart_grievance/features/profile/logic/profile_controller.dart';
import 'package:smart_grievance/features/profile/presentation/setup_profile_screen.dart';
import 'package:smart_grievance/features/profile/widgets/profile_avatar_picker.dart';

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

class _TestProfileController implements ProfileController {
  _TestProfileController({
    this.shouldSucceed = true,
    this.errorMessage,
  });

  final bool shouldSucceed;
  final String? errorMessage;
  int saveCalls = 0;
  UserProfile? savedProfile;

  @override
  UserProfile? get currentProfile => savedProfile;

  @override
  Future<ProfileResult> saveProfile(UserProfile profile) async {
    saveCalls++;
    savedProfile = profile;
    return ProfileResult(
      isSuccess: shouldSucceed,
      message: shouldSucceed ? 'Profile saved' : (errorMessage ?? 'Save failed'),
    );
  }
}

class _TestPhotoPickerService implements PhotoPickerService {
  PhotoPickResult? mockResult;

  @override
  Future<PhotoPickResult?> pickFromGallery() async => mockResult;

  @override
  Future<PhotoPickResult?> captureWithCamera() async => mockResult;
}

Widget _buildTestApp({
  String phoneNumber = '9876543210',
  ProfileController? controller,
  DistrictProvider? districtProvider,
  PhotoPickerService? photoService,
}) {
  return DefaultAssetBundle(
    bundle: _ProjectAssetBundle(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/allow-access': (_) => const Scaffold(body: Text('Allow Access Screen')),
      },
      home: SetupProfileScreen(
        phoneNumber: phoneNumber,
        profileController: controller ?? _TestProfileController(),
        districtProvider: districtProvider ??
            const ConfiguredDistrictProvider(
              initialDistricts: ['Central District', 'North District', 'South District'],
            ),
        photoPickerService: photoService ?? _TestPhotoPickerService(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Validation Unit Logic', () {
    test('validateFullName rejects empty or single-character names', () {
      expect(validateFullName(''), equals('Please enter your full name'));
      expect(validateFullName('   '), equals('Please enter your full name'));
      expect(validateFullName('A'), equals('Full name must be at least 2 characters'));
      expect(validateFullName('John Doe'), isNull);
    });

    test('validateEmail allows null or empty, rejects invalid formats', () {
      expect(validateEmail(''), isNull);
      expect(validateEmail(null), isNull);
      expect(validateEmail('invalid-email'), equals('Please enter a valid email address'));
      expect(validateEmail('test@'), equals('Please enter a valid email address'));
      expect(validateEmail('citizen@example.com'), isNull);
    });

    test('validateDistrict rejects empty selection', () {
      expect(validateDistrict(''), equals('Please select your district'));
      expect(validateDistrict(null), equals('Please select your district'));
      expect(validateDistrict('Central District'), isNull);
    });
  });

  group('SetupProfileScreen Widget & Interaction Tests', () {
    testWidgets('renders all core UI elements cleanly', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      // Heading and back button
      expect(find.text('Set Up Your Profile'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Avatar picker
      expect(find.byType(ProfileAvatarPicker), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // Form fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email (Optional)'), findsOneWidget);
      expect(find.text('District / City'), findsOneWidget);
      expect(find.text('Select District'), findsOneWidget);

      // Continue CTA button
      expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    });

    testWidgets('submitting empty form triggers validation errors', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final continueFinder = find.widgetWithText(FilledButton, 'Continue');
      await tester.ensureVisible(continueFinder);
      await tester.tap(continueFinder);
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please select your district'), findsOneWidget);
      // Optional email should not show an error
      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('invalid email shows format error', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final textFields = find.byType(TextField);
      // Enter valid name
      await tester.enterText(textFields.at(0), 'Aditi Sharma');
      // Enter invalid email
      await tester.enterText(textFields.at(1), 'notanemail');
      await tester.pump();

      final continueFinder = find.widgetWithText(FilledButton, 'Continue');
      await tester.ensureVisible(continueFinder);
      await tester.tap(continueFinder);
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('selecting district from bottom sheet updates field', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      final districtFinder = find.text('Select District');
      await tester.ensureVisible(districtFinder);
      await tester.tap(districtFinder);
      await tester.pumpAndSettle();

      // Tap 'Central District'
      await tester.tap(find.text('Central District').last);
      await tester.pumpAndSettle();

      expect(find.text('Central District'), findsOneWidget);
    });

    testWidgets('valid form submission calls ProfileController and shows success snackbar', (tester) async {
      final mockController = _TestProfileController(shouldSucceed: true);
      await tester.pumpWidget(_buildTestApp(controller: mockController));
      await tester.pump();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Rohit Kumar');
      await tester.enterText(textFields.at(1), 'rohit@example.com');
      await tester.pump();

      // Select district
      final districtFinder = find.text('Select District');
      await tester.ensureVisible(districtFinder);
      await tester.tap(districtFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('North District').last);
      await tester.pumpAndSettle();

      // Submit
      final continueFinder = find.widgetWithText(FilledButton, 'Continue');
      await tester.ensureVisible(continueFinder);
      await tester.tap(continueFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(mockController.saveCalls, equals(1));
      expect(mockController.savedProfile?.fullName, equals('Rohit Kumar'));
      expect(mockController.savedProfile?.email, equals('rohit@example.com'));
      expect(mockController.savedProfile?.district, equals('North District'));
      expect(mockController.savedProfile?.phoneNumber, equals('9876543210'));
      expect(find.text('Profile saved successfully!'), findsOneWidget);
    });

    testWidgets('backend save error displays error message', (tester) async {
      final mockController = _TestProfileController(
        shouldSucceed: false,
        errorMessage: 'Network timeout. Could not save profile.',
      );
      await tester.pumpWidget(_buildTestApp(controller: mockController));
      await tester.pump();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Rohit Kumar');
      await tester.pump();

      // Select district
      final districtFinder = find.text('Select District');
      await tester.ensureVisible(districtFinder);
      await tester.tap(districtFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('South District').last);
      await tester.pumpAndSettle();

      // Submit
      final continueFinder = find.widgetWithText(FilledButton, 'Continue');
      await tester.ensureVisible(continueFinder);
      await tester.tap(continueFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('Network timeout. Could not save profile.'), findsOneWidget);
    });

    group('Responsive Viewport Tests', () {
      testWidgets('renders cleanly on small screen (320x568) without overflow', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SetupProfileScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (390x844) without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SetupProfileScreen), findsOneWidget);
      });

      testWidgets('renders cleanly on large screen (430x932) without overflow', (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SetupProfileScreen), findsOneWidget);
      });
    });
  });
}
