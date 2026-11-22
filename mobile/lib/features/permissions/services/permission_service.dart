/// Abstraction for platform permission handling.
///
/// On web, permissions are stubbed as [PermissionState.granted] since
/// the web platform does not use native permission gates for location,
/// camera, or notifications in the same way that Android/iOS do.
///
/// When Android/iOS targets are added, replace the web stubs with the
/// `permission_handler` package (or similar) to request real OS permissions.
library;

/// Represents the three permissions the app uses.
enum AppPermission { location, camera, notifications }

/// Platform-level permission state.
enum PermissionState {
  /// Not yet requested.
  undetermined,

  /// The user granted the permission.
  granted,

  /// The user denied the permission (may be re-prompted).
  denied,

  /// The user permanently denied the permission (must open settings).
  permanentlyDenied,
}

/// Contract for checking and requesting permissions.
abstract class PermissionService {
  /// Check the current status of [permission] without prompting the user.
  Future<PermissionState> check(AppPermission permission);

  /// Request [permission] from the operating system.
  /// Returns the resulting state.
  Future<PermissionState> request(AppPermission permission);

  /// Open the device's app settings page so the user can manually toggle
  /// a permanently-denied permission.
  Future<bool> openSettings();
}

/// Web / test stub that always grants permissions.
///
/// Replace with a real implementation when Android/iOS native targets
/// are added to the project.
class StubPermissionService implements PermissionService {
  /// Optional overrides for testing specific denial flows.
  final Map<AppPermission, PermissionState> _overrides;

  const StubPermissionService({
    Map<AppPermission, PermissionState> overrides = const {},
  }) : _overrides = overrides;

  @override
  Future<PermissionState> check(AppPermission permission) async {
    return _overrides[permission] ?? PermissionState.undetermined;
  }

  @override
  Future<PermissionState> request(AppPermission permission) async {
    return _overrides[permission] ?? PermissionState.granted;
  }

  @override
  Future<bool> openSettings() async {
    // Cannot open native settings on web.
    return false;
  }
}

