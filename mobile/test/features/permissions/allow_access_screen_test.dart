import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/permissions/logic/permission_controller.dart';
import 'package:smart_grievance/features/permissions/presentation/allow_access_screen.dart';
import 'package:smart_grievance/features/permissions/services/permission_service.dart';
import 'package:smart_grievance/features/permissions/widgets/permission_card.dart';

class _FakePermissionService implements PermissionService {
  _FakePermissionService({
    this.initialStates = const {},
    this.requestResults = const {},
  });

  final Map<AppPermission, PermissionState> initialStates;
  final Map<AppPermission, PermissionState> requestResults;

  final List<AppPermission> checkCalls = [];
  final List<AppPermission> requestCalls = [];
  int openSettingsCalls = 0;

  @override
  Future<PermissionState> check(AppPermission permission) async {
    checkCalls.add(permission);
    return initialStates[permission] ?? PermissionState.undetermined;
  }

  @override
  Future<PermissionState> request(AppPermission permission) async {
    requestCalls.add(permission);
    return requestResults[permission] ?? PermissionState.granted;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCalls++;
    return true;
  }
}

Widget _buildTestApp({
  PermissionService? service,
  NavigatorObserver? observer,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorObservers: observer != null ? [observer] : [],
    routes: {
      '/home': (_) => const Scaffold(body: Text('Home Screen')),
    },
    home: AllowAccessScreen(
      permissionService: service ?? _FakePermissionService(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PermissionController Logic Tests', () {
    test('initializes with undetermined status by default', () async {
      final fakeService = _FakePermissionService();
      final controller = PermissionController(service: fakeService);

      await controller.init();

      expect(controller.locationEnabled, isFalse);
      expect(controller.cameraEnabled, isFalse);
      expect(controller.notificationsEnabled, isFalse);
      expect(controller.locationState, equals(PermissionState.undetermined));
      expect(controller.cameraState, equals(PermissionState.undetermined));
      expect(controller.notificationsState, equals(PermissionState.undetermined));
    });

    test('toggling on requests permission and updates enabled state if granted', () async {
      final fakeService = _FakePermissionService(
        requestResults: {
          AppPermission.location: PermissionState.granted,
        },
      );
      final controller = PermissionController(service: fakeService);
      await controller.init();

      await controller.togglePermission(AppPermission.location);

      expect(controller.locationEnabled, isTrue);
      expect(controller.locationState, equals(PermissionState.granted));
      expect(fakeService.requestCalls, contains(AppPermission.location));
    });

    test('toggling off sets enabled to false without calling request', () async {
      final fakeService = _FakePermissionService(
        initialStates: {
          AppPermission.location: PermissionState.granted,
        },
      );
      final controller = PermissionController(service: fakeService);
      await controller.init();
      expect(controller.locationEnabled, isTrue);

      await controller.togglePermission(AppPermission.location);

      expect(controller.locationEnabled, isFalse);
      expect(fakeService.requestCalls, isEmpty);
    });

    test('permanently denied permission opens settings on toggle', () async {
      final fakeService = _FakePermissionService(
        initialStates: {
          AppPermission.camera: PermissionState.permanentlyDenied,
        },
      );
      final controller = PermissionController(service: fakeService);
      await controller.init();

      await controller.togglePermission(AppPermission.camera);

      expect(fakeService.openSettingsCalls, equals(1));
      expect(controller.cameraEnabled, isFalse);
    });

    test('processAndContinue requests only enabled ungranted permissions', () async {
      final fakeService = _FakePermissionService(
        initialStates: {
          AppPermission.location: PermissionState.undetermined,
          AppPermission.camera: PermissionState.granted,
          AppPermission.notifications: PermissionState.undetermined,
        },
        requestResults: {
          AppPermission.location: PermissionState.granted,
        },
      );
      final controller = PermissionController(service: fakeService);
      await controller.init();

      // Set preference for location without calling request immediately
      controller.setPreference(AppPermission.location, true);
      fakeService.requestCalls.clear();

      await controller.processAndContinue();

      expect(fakeService.requestCalls, contains(AppPermission.location));
      expect(fakeService.requestCalls, isNot(contains(AppPermission.notifications)));
    });
  });

  group('AllowAccessScreen Widget & Interaction Tests', () {
    testWidgets('renders all core UI elements cleanly', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Allow Access'), findsOneWidget);
      expect(
        find.text('We need a few permissions to make\nyour experience better.'),
        findsOneWidget,
      );
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('To capture the exact issue location'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('To upload photos or videos'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('To keep you updated on your grievances'), findsOneWidget);
      expect(find.text('Allow & Continue'), findsOneWidget);
      expect(find.byType(PermissionCard), findsNWidgets(3));
      expect(find.byType(Switch), findsNWidgets(3));
    });

    testWidgets('toggling switch updates its visual state', (tester) async {
      final fakeService = _FakePermissionService(
        requestResults: {
          AppPermission.location: PermissionState.granted,
        },
      );
      await tester.pumpWidget(_buildTestApp(service: fakeService));
      await tester.pumpAndSettle();

      final firstSwitch = find.byType(Switch).first;
      expect((tester.widget(firstSwitch) as Switch).value, isFalse);

      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();

      expect((tester.widget(find.byType(Switch).first) as Switch).value, isTrue);
    });

    testWidgets('permanently denied permission shows explanatory text', (tester) async {
      final fakeService = _FakePermissionService(
        initialStates: {
          AppPermission.camera: PermissionState.permanentlyDenied,
        },
      );
      await tester.pumpWidget(_buildTestApp(service: fakeService));
      await tester.pumpAndSettle();

      expect(find.text('Denied. Tap toggle to open settings.'), findsOneWidget);
    });

    testWidgets('tapping Allow & Continue navigates to /home', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final continueButton = find.text('Allow & Continue');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });

    group('Responsive Viewport Tests', () {
      testWidgets('renders cleanly on small screen (320x568) without overflow', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Allow Access'), findsOneWidget);
        expect(find.text('Allow & Continue'), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (390x844) without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Allow Access'), findsOneWidget);
        expect(find.text('Allow & Continue'), findsOneWidget);
      });

      testWidgets('renders cleanly on large screen (430x932) without overflow', (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Allow Access'), findsOneWidget);
        expect(find.text('Allow & Continue'), findsOneWidget);
      });
    });
  });
}
