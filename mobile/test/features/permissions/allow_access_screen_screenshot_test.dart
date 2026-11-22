import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_grievance/features/permissions/presentation/allow_access_screen.dart';
import 'package:smart_grievance/features/permissions/services/permission_service.dart';

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

  const iconPath =
      r'C:\flutter\sdk\flutter_windows_3.41.7-stable\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf';
  final iconFile = File(iconPath);
  if (iconFile.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    iconLoader.addFont(Future.value(ByteData.view(iconFile.readAsBytesSync().buffer)));
    await iconLoader.load();
  }
}

Widget _buildCaptureApp() {
  return DefaultAssetBundle(
    bundle: _ProjectAssetBundle(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return const AllowAccessScreen(
            permissionService: StubPermissionService(),
          );
        },
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('capture allow access screen golden - 360x800', (tester) async {
    await tester.runAsync(() async {
      await _loadFonts();
    });

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildCaptureApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AllowAccessScreen),
      matchesGoldenFile('goldens/allow_access_360x800.png'),
    );
  });

  testWidgets('capture allow access screen golden - 375x812', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildCaptureApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AllowAccessScreen),
      matchesGoldenFile('goldens/allow_access_375x812.png'),
    );
  });

  testWidgets('capture allow access screen golden - 390x844', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildCaptureApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AllowAccessScreen),
      matchesGoldenFile('goldens/allow_access_390x844.png'),
    );
  });

  testWidgets('capture allow access screen golden - small viewport (320x568)', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildCaptureApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AllowAccessScreen),
      matchesGoldenFile('goldens/allow_access_screen_small.png'),
    );
  });
}
