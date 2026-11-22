import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/home/logic/dashboard_controller.dart';
import 'package:smart_grievance/features/home/presentation/home_dashboard_screen.dart';
import 'package:smart_grievance/features/home/widgets/dashboard_bottom_navigation.dart';
import 'package:smart_grievance/features/home/widgets/dashboard_header.dart';
import 'package:smart_grievance/features/home/widgets/quick_action_card.dart';
import 'package:smart_grievance/features/home/widgets/quick_action_grid.dart';
import 'package:smart_grievance/features/home/widgets/submit_grievance_card.dart';
import 'package:smart_grievance/features/home/widgets/welcome_section.dart';

class _FakeDashboardDataProvider implements DashboardDataProvider {
  _FakeDashboardDataProvider({
    this.name = 'Rahul Sharma',
    this.unreadCount = 3,
  });

  final String? name;
  final int unreadCount;

  @override
  Future<String?> fetchCitizenName() async {
    return name;
  }

  @override
  Future<int> fetchUnreadNotificationCount() async {
    return unreadCount;
  }
}

Widget _buildTestApp({
  DashboardDataProvider? dataProvider,
  DashboardController? controller,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/submit-grievance': (_) => const Scaffold(body: Text('Submit Screen')),
      '/my-grievances': (_) => const Scaffold(body: Text('My Grievances Screen')),
      '/grievance-map': (_) => const Scaffold(body: Text('Grievance Map Screen')),
      '/profile': (_) => const Scaffold(body: Text('Profile Screen')),
      '/setup-profile': (_) => const Scaffold(body: Text('Setup Profile Screen')),
    },
    home: HomeDashboardScreen(
      controller: controller ??
          DashboardController(
            dataProvider: dataProvider ?? _FakeDashboardDataProvider(),
          ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardController Unit Tests', () {
    test('loads citizen name and notification count successfully', () async {
      final fakeProvider = _FakeDashboardDataProvider(
        name: 'Priya Patel',
        unreadCount: 5,
      );
      final controller = DashboardController(dataProvider: fakeProvider);

      await controller.loadDashboardData();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.citizenName, equals('Priya Patel'));
      expect(controller.state.unreadNotificationCount, equals(5));
      expect(controller.state.errorMessage, isNull);
    });

    test('handles fallback to null name when unauthenticated', () async {
      final fakeProvider = _FakeDashboardDataProvider(name: null, unreadCount: 0);
      final controller = DashboardController(dataProvider: fakeProvider);

      await controller.loadDashboardData();

      expect(controller.state.citizenName, isNull);
      expect(controller.state.unreadNotificationCount, equals(0));
    });

    test('updates tab index on selection', () {
      final controller = DashboardController();
      expect(controller.selectedTabIndex, equals(0));

      controller.setTabIndex(2);
      expect(controller.selectedTabIndex, equals(2));
    });
  });

  group('HomeDashboardScreen Widget & Interaction Tests', () {
    testWidgets('renders all core UI elements cleanly', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Header
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(3)); // Logo, cityscape, and bottom-right wave

      // Welcome Section
      expect(find.byType(WelcomeSection), findsOneWidget);
      expect(find.text('Hello, Rahul Sharma!'), findsOneWidget);
      expect(
        find.text('Your voice matters. Report an issue and get it resolved.'),
        findsOneWidget,
      );

      // Primary CTA
      expect(find.byType(SubmitGrievanceCard), findsOneWidget);
      expect(find.text('Submit a Grievance'), findsOneWidget);

      // Quick Action Grid & Cards
      expect(find.byType(QuickActionGrid), findsOneWidget);
      expect(find.byType(QuickActionCard), findsNWidgets(4));
      expect(find.text('Track My Grievances'), findsOneWidget);
      expect(find.text('Grievance Map'), findsOneWidget);
      expect(find.text('View Updates'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);

      // Bottom Navigation
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
      expect(find.descendant(of: find.byType(DashboardBottomNavigation), matching: find.text('Home')), findsOneWidget);
      expect(find.descendant(of: find.byType(DashboardBottomNavigation), matching: find.text('Grievance')), findsOneWidget);
      expect(find.descendant(of: find.byType(DashboardBottomNavigation), matching: find.text('Map')), findsOneWidget);
      expect(find.descendant(of: find.byType(DashboardBottomNavigation), matching: find.text('Profile')), findsOneWidget);
    });

    testWidgets('renders fallback "Hello, Citizen!" when name is null', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(dataProvider: _FakeDashboardDataProvider(name: null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello, Citizen!'), findsOneWidget);
    });

    testWidgets('tapping Submit Grievance card navigates to submit grievance screen', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit a Grievance'));
      await tester.pumpAndSettle();

      expect(find.text('Submit Screen'), findsOneWidget);
    });

    testWidgets('tapping Quick Action cards navigates to corresponding screens or shows placeholder', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Track My Grievances'));
      await tester.pumpAndSettle();
      expect(find.text('My Grievances Screen'), findsOneWidget);
    });

    testWidgets('tapping bottom navigation tabs updates selection and navigates', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(of: find.byType(DashboardBottomNavigation), matching: find.text('Grievance')));
      await tester.pumpAndSettle();
      expect(find.text('My Grievances Screen'), findsOneWidget);
    });

    group('Responsive Viewport Tests (No Scrolling)', () {
      testWidgets('renders cleanly on standard screen (360x800) without overflow', (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Submit a Grievance'), findsOneWidget);
        expect(find.text('Track My Grievances'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (375x812) without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Submit a Grievance'), findsOneWidget);
        expect(find.text('Track My Grievances'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('renders cleanly on standard screen (390x844) without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Submit a Grievance'), findsOneWidget);
        expect(find.text('Track My Grievances'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      });
    });
  });
}
