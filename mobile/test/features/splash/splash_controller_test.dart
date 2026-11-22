import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/splash/logic/splash_controller.dart';

void main() {
  group('SplashController', () {
    late SplashController controller;

    setUp(() {
      controller = SplashController();
    });

    test('initial state is not initialized and auth is null', () {
      expect(controller.isInitialized, isFalse);
      expect(controller.isAuthenticated, isNull);
    });

    test('initialize completes and sets isInitialized to true', () async {
      await controller.initialize();
      expect(controller.isInitialized, isTrue);
    });

    test('initialize sets isAuthenticated to false (placeholder)', () async {
      await controller.initialize();
      // TEMPORARY: always false until real auth is implemented.
      expect(controller.isAuthenticated, isFalse);
    });
  });
}

