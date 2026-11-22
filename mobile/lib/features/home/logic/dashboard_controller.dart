import 'package:flutter/foundation.dart';
import '../../notifications/logic/notification_controller.dart';
import '../../profile/logic/profile_controller.dart';

/// State representation for the Citizen Home Dashboard.
class DashboardState {
  const DashboardState({
    this.citizenName,
    this.unreadNotificationCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? citizenName;
  final int unreadNotificationCount;
  final bool isLoading;
  final String? errorMessage;

  DashboardState copyWith({
    String? citizenName,
    int? unreadNotificationCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      citizenName: citizenName ?? this.citizenName,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Abstract contract for dashboard data operations.
abstract class DashboardDataProvider {
  Future<String?> fetchCitizenName();
  Future<int> fetchUnreadNotificationCount();
}

/// Default provider reading from the authenticated session / profile controller.
class AuthenticatedDashboardDataProvider implements DashboardDataProvider {
  AuthenticatedDashboardDataProvider({ProfileController? profileController})
      : _profileController = profileController ?? StubProfileController.instance;

  final ProfileController _profileController;

  @override
  Future<String?> fetchCitizenName() async {
    return _profileController.currentProfile?.fullName;
  }

  @override
  Future<int> fetchUnreadNotificationCount() async {
    return NotificationController.instance.unreadCount;
  }
}

/// Controller managing dashboard lifecycle and state.
class DashboardController extends ChangeNotifier {
  DashboardController({DashboardDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? AuthenticatedDashboardDataProvider() {
    // Listen to notification changes to keep unread count live
    NotificationController.instance.addListener(_onExternalDataChanged);
    StubProfileController.instance.addListener(_onExternalDataChanged);
  }

  final DashboardDataProvider _dataProvider;

  void _onExternalDataChanged() {
    loadDashboardData();
  }

  @override
  void dispose() {
    NotificationController.instance.removeListener(_onExternalDataChanged);
    StubProfileController.instance.removeListener(_onExternalDataChanged);
    super.dispose();
  }

  DashboardState _state = const DashboardState(isLoading: true);
  DashboardState get state => _state;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final name = await _dataProvider.fetchCitizenName();
      final unreadCount = await _dataProvider.fetchUnreadNotificationCount();

      _state = DashboardState(
        citizenName: name,
        unreadNotificationCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      _state = DashboardState(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data: $e',
      );
    }
    notifyListeners();
  }
}

