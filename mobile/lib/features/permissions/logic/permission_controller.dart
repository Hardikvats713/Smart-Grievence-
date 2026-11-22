import 'package:flutter/foundation.dart';
import '../services/permission_service.dart';

/// Manages citizen permission preferences and coordinates OS permission
/// requests through [PermissionService].
///
/// Keeps the citizen's *intent* (toggle on/off) separate from the actual
/// OS-level permission state. A toggle being "on" means the citizen
/// *wants* to grant it — the OS may still deny or require settings.
class PermissionController extends ChangeNotifier {
  PermissionController({
    PermissionService? service,
  }) : _service = service ?? const StubPermissionService();

  final PermissionService _service;

  // ── Citizen preference toggles ──────────────────────────────────────
  bool _locationEnabled = false;
  bool _cameraEnabled = false;
  bool _notificationsEnabled = false;

  bool get locationEnabled => _locationEnabled;
  bool get cameraEnabled => _cameraEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  // ── Actual OS permission states ─────────────────────────────────────
  PermissionState _locationState = PermissionState.undetermined;
  PermissionState _cameraState = PermissionState.undetermined;
  PermissionState _notificationsState = PermissionState.undetermined;

  PermissionState get locationState => _locationState;
  PermissionState get cameraState => _cameraState;
  PermissionState get notificationsState => _notificationsState;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  /// Explicitly set the citizen preference for a permission without immediately requesting OS access.
  void setPreference(AppPermission permission, bool enabled) {
    switch (permission) {
      case AppPermission.location:
        _locationEnabled = enabled;
      case AppPermission.camera:
        _cameraEnabled = enabled;
      case AppPermission.notifications:
        _notificationsEnabled = enabled;
    }
    notifyListeners();
  }

  /// Initialise by checking current OS permission states.
  Future<void> init() async {
    _locationState = await _service.check(AppPermission.location);
    _cameraState = await _service.check(AppPermission.camera);
    _notificationsState = await _service.check(AppPermission.notifications);

    // If already granted, reflect in toggles
    _locationEnabled = _locationState == PermissionState.granted;
    _cameraEnabled = _cameraState == PermissionState.granted;
    _notificationsEnabled = _notificationsState == PermissionState.granted;

    notifyListeners();
  }

  /// Toggle a permission on/off. If toggling on AND the permission was
  /// previously permanently denied, prompt to open settings instead.
  Future<void> togglePermission(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        if (_locationEnabled) {
          _locationEnabled = false;
        } else {
          if (_locationState == PermissionState.permanentlyDenied) {
            await _service.openSettings();
            return;
          }
          final result = await _service.request(permission);
          _locationState = result;
          _locationEnabled = result == PermissionState.granted;
        }
      case AppPermission.camera:
        if (_cameraEnabled) {
          _cameraEnabled = false;
        } else {
          if (_cameraState == PermissionState.permanentlyDenied) {
            await _service.openSettings();
            return;
          }
          final result = await _service.request(permission);
          _cameraState = result;
          _cameraEnabled = result == PermissionState.granted;
        }
      case AppPermission.notifications:
        if (_notificationsEnabled) {
          _notificationsEnabled = false;
        } else {
          if (_notificationsState == PermissionState.permanentlyDenied) {
            await _service.openSettings();
            return;
          }
          final result = await _service.request(permission);
          _notificationsState = result;
          _notificationsEnabled = result == PermissionState.granted;
        }
    }
    notifyListeners();
  }

  /// Process enabled permissions that haven't been granted yet,
  /// then navigate forward regardless of results.
  Future<void> processAndContinue() async {
    _isProcessing = true;
    notifyListeners();

    // Request only permissions the citizen opted in to that aren't granted yet
    if (_locationEnabled && _locationState != PermissionState.granted) {
      _locationState = await _service.request(AppPermission.location);
      _locationEnabled = _locationState == PermissionState.granted;
    }

    if (_cameraEnabled && _cameraState != PermissionState.granted) {
      _cameraState = await _service.request(AppPermission.camera);
      _cameraEnabled = _cameraState == PermissionState.granted;
    }

    if (_notificationsEnabled &&
        _notificationsState != PermissionState.granted) {
      _notificationsState =
          await _service.request(AppPermission.notifications);
      _notificationsEnabled =
          _notificationsState == PermissionState.granted;
    }

    _isProcessing = false;
    notifyListeners();
  }
}

