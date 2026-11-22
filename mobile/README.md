# Flutter mobile application

Create the Flutter app in this directory.

Recommended feature-first structure:

lib/
  main.dart
  app/
    app.dart
    router.dart
  core/
    theme/
      app_colors.dart
      app_typography.dart
      app_dimensions.dart
      app_theme.dart
    widgets/
      glass_button.dart
      primary_button.dart
      secondary_button.dart
      app_card.dart
      app_input.dart
      app_header.dart
      app_bottom_navigation.dart
      status_chip.dart
  features/
    splash/
    onboarding/
    authentication/
    profile/
    home/
    grievance_submission/
    grievance_tracking/
    grievance_map/
    notifications/
    officer/
  services/
  models/

Run `flutter create .` from this directory when Flutter is installed and this directory is empty of generated Flutter platform files. Review before running if files already exist.

Add packages only when needed and pin compatible versions in `pubspec.yaml`.
