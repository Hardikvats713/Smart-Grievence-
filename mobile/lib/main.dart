import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'features/profile/logic/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted user profile and avatar bytes from local storage
  await StubProfileController.instance.loadFromStorage();

  // Set status bar to match the Warm Ivory background.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF3EEE8),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const SmartGrievanceApp());
}

