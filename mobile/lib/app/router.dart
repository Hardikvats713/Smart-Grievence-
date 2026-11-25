import 'package:flutter/material.dart';
import '../features/auth/presentation/get_started_screen.dart';
import '../features/auth/presentation/role_selection_screen.dart';
import '../features/auth/presentation/verify_otp_screen.dart';
import '../features/grievances/category_forms/electricity_grievance_screen.dart';
import '../features/grievances/category_forms/sanitation_grievance_screen.dart';
import '../features/grievances/category_forms/water_supply_grievance_screen.dart';
import '../features/grievances/feedback/resolution_feedback_screen.dart';
import '../features/grievances/presentation/grievance_detail_timeline_screen.dart';
import '../features/grievances/presentation/grievance_details_screen.dart';
import '../features/grievances/presentation/grievance_location_screen.dart';
import '../features/grievances/presentation/grievance_map_screen.dart';
import '../features/grievances/presentation/my_grievances_screen.dart';
import '../features/grievances/presentation/review_submit_screen.dart';
import '../features/grievances/presentation/select_category_screen.dart';
import '../features/grievances/presentation/submission_confirmation_screen.dart';
import '../features/grievances/reopen/reopen_grievance_screen.dart';
import '../features/home/presentation/home_dashboard_screen.dart';
import '../features/how_it_works/presentation/how_it_works_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/officer/presentation/officer_dashboard_screen.dart';
import '../features/officer/presentation/officer_grievance_action_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/permissions/presentation/allow_access_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_settings_screen.dart';
import '../features/profile/presentation/setup_profile_screen.dart';
import '../features/profile/saved_addresses/saved_addresses_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

/// Centralized route definitions connecting Screens 01 to 25.
abstract final class AppRouter {
  // Screens 01 to 07
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String authPlaceholder = '/auth-placeholder';
  static const String getStarted = '/get-started';
  static const String verifyOtp = '/verify-otp';
  static const String roleSelection = '/role-selection';
  static const String setupProfile = '/setup-profile';
  static const String allowAccess = '/allow-access';
  static const String home = '/home';

  // Grievance submission flow (Screens 08 to 12)
  static const String submitCategory = '/submit-grievance';
  static const String submitDetails = '/submit-grievance/details';
  static const String submitLocation = '/submit-grievance/location';
  static const String submitReview = '/submit-grievance/review';
  static const String submitConfirmation = '/submit-grievance/confirmation';

  // Category specific forms (Screens 19 to 21)
  static const String submitElectricity = '/submit-grievance/electricity';
  static const String submitWaterSupply = '/submit-grievance/water-supply';
  static const String submitSanitation = '/submit-grievance/sanitation';

  // Tracking, GIS Map and Post-Resolution (Screens 13 to 15, 24, 25)
  static const String myGrievances = '/my-grievances';
  static const String grievanceDetails = '/grievance-details';
  static const String grievanceMap = '/grievance-map';
  static const String resolutionFeedback = '/grievance/feedback';
  static const String reopenGrievance = '/grievance/reopen';

  // Additional Citizen Features (Screens 17, 18)
  static const String notifications = '/notifications';
  static const String howItWorks = '/how-it-works';

  // Profile & Saved Addresses (Screens 16, 22, 23)
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String savedAddresses = '/profile/saved-addresses';

  // Officer & Supervisory Portal (Role-Based Access)
  static const String officerDashboard = '/officer-dashboard';
  static const String officerGrievanceAction = '/officer/grievance-action';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        welcome: (_) => const WelcomeScreen(),
        authPlaceholder: (_) => const GetStartedScreen(),
        getStarted: (_) => const GetStartedScreen(),
        verifyOtp: (_) => const VerifyOtpScreen(),
        roleSelection: (_) => const RoleSelectionScreen(),
        setupProfile: (_) => const SetupProfileScreen(),
        allowAccess: (_) => const AllowAccessScreen(),
        home: (_) => const HomeDashboardScreen(),
        submitCategory: (_) => const SelectCategoryScreen(),
        submitDetails: (_) => const GrievanceDetailsScreen(),
        submitElectricity: (_) => const ElectricityGrievanceScreen(),
        submitWaterSupply: (_) => const WaterSupplyGrievanceScreen(),
        submitSanitation: (_) => const SanitationGrievanceScreen(),
        submitLocation: (_) => const GrievanceLocationScreen(),
        submitReview: (_) => const ReviewSubmitScreen(),
        submitConfirmation: (_) => const SubmissionConfirmationScreen(),
        myGrievances: (_) => const MyGrievancesScreen(),
        grievanceDetails: (context) {
          final id = ModalRoute.of(context)?.settings.arguments as String?;
          return GrievanceDetailTimelineScreen(grievanceId: id);
        },
        grievanceMap: (_) => const GrievanceMapScreen(),
        resolutionFeedback: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ResolutionFeedbackScreen(
            grievanceReference: args?['reference'] ?? 'SG2503170005',
            grievanceId: args?['id'] ?? 'g-2',
          );
        },
        reopenGrievance: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ReopenGrievanceScreen(
            grievanceReference: args?['reference'] ?? 'SG2503170005',
            grievanceId: args?['id'] ?? 'g-2',
          );
        },
        notifications: (_) => const NotificationsScreen(),
        howItWorks: (_) => const HowItWorksScreen(),
        profile: (_) => const ProfileSettingsScreen(),
        editProfile: (_) => const EditProfileScreen(),
        savedAddresses: (_) => const SavedAddressesScreen(),
        officerDashboard: (_) => const OfficerDashboardScreen(),
        officerGrievanceAction: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return OfficerGrievanceActionScreen(grievance: args);
        },
      };
}
