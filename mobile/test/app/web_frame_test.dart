import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/app/app.dart';

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
  testWidgets('capture desktop web framed preview', (tester) async {
    final bundle = _ProjectAssetBundle();

    tester.view.physicalSize = const Size(800, 920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late BuildContext savedContext;

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return const SmartGrievanceApp();
          },
        ),
      ),
    );

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

    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byType(SmartGrievanceApp),
      matchesGoldenFile('goldens/web_framed_preview.png'),
    );
  });
}
