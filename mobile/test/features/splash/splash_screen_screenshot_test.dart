import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/splash/logic/splash_controller.dart';
import 'package:smart_grievance/features/splash/presentation/splash_screen.dart';

class _CapturingController extends SplashController {
  final Completer<void> _completer = Completer<void>();
  @override
  Future<void> initialize() => _completer.future;
}

/// AssetBundle that loads real bytes from the project directory.
class _ProjectAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final candidates = [
      key,
      'mobile/$key',
      'c:/Users/Hardik/Downloads/SMART-GRIEVANCE_READY_TO_START/SMART-GRIEVANCE-READY/mobile/$key',
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

void main() {
  testWidgets('splash screen visual capture with real assets', (tester) async {
    final controller = _CapturingController();
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
              return SplashScreen(controller: controller);
            },
          ),
        ),
      ),
    );

    // Precache both images using runAsync so the engine decodes the PNGs
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/smart_grievance_logo.png'),
        savedContext,
      );
      await precacheImage(
        const AssetImage('assets/images/splash_cityscape.png'),
        savedContext,
      );
    });

    // Pump frames to complete the 300ms logo fade/scale animation
    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byType(SplashScreen),
      matchesGoldenFile('goldens/splash_screen.png'),
    );
  });
}
