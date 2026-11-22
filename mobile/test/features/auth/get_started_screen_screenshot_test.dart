import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/auth/presentation/get_started_screen.dart';

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

Future<void> _loadFonts() async {
  final fontLoader = FontLoader('Poppins');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final candidates = [
      'assets/fonts/Poppins-$weight.ttf',
      'mobile/assets/fonts/Poppins-$weight.ttf',
      'c:/Users/Hardik/Downloads/SMART-GRIEVANCE_READY_TO_START/SMART-GRIEVANCE-READY/mobile/assets/fonts/Poppins-$weight.ttf',
      'SMART-GRIEVANCE-READY/mobile/assets/fonts/Poppins-$weight.ttf',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) {
        fontLoader.addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
        break;
      }
    }
  }
  await fontLoader.load();
}

void main() {
  testWidgets('capture get started screen golden', (tester) async {
    await tester.runAsync(() async {
      await _loadFonts();
    });

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
              return const GetStartedScreen();
            },
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/smart_grievance_logo.png'),
        savedContext,
      );
      await precacheImage(
        const AssetImage('assets/images/get_started_cityscape.png'),
        savedContext,
      );
    });

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GetStartedScreen),
      matchesGoldenFile('goldens/get_started_screen.png'),
    );
  });
}
