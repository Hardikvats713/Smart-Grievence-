import 'package:flutter/foundation.dart';
import '../models/grievance_model.dart';
import '../services/grievance_service.dart';

/// Form draft state accumulated during Screens 08, 09, 10, 11.
class GrievanceDraft {
  const GrievanceDraft({
    this.category,
    this.title = '',
    this.description = '',
    this.locationAddress = 'Main Road, Sector 12, Itanagar, Arunachal Pradesh',
    this.latitude = 27.1025,
    this.longitude = 93.6160,
    this.attachments = const [],
  });

  final GrievanceCategory? category;
  final String title;
  final String description;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final List<String> attachments;

  bool get isCategoryValid => category != null;
  bool get isDetailsValid => title.trim().isNotEmpty && description.trim().isNotEmpty;
  bool get isLocationValid => locationAddress.trim().isNotEmpty;
  bool get isComplete => isCategoryValid && isDetailsValid && isLocationValid;

  GrievanceDraft copyWith({
    GrievanceCategory? category,
    String? title,
    String? description,
    String? locationAddress,
    double? latitude,
    double? longitude,
    List<String>? attachments,
  }) {
    return GrievanceDraft(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      attachments: attachments ?? this.attachments,
    );
  }
}

/// Global/singleton or shared controller for grievance draft & tracking.
class GrievanceController extends ChangeNotifier {
  GrievanceController({GrievanceService? service})
      : _service = service ?? StubGrievanceService();

  static final GrievanceController instance = GrievanceController();

  final GrievanceService _service;

  GrievanceDraft _draft = const GrievanceDraft();
  GrievanceDraft get draft => _draft;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _submissionError;
  String? get submissionError => _submissionError;

  Grievance? _lastSubmittedGrievance;
  Grievance? get lastSubmittedGrievance => _lastSubmittedGrievance;

  void selectCategory(GrievanceCategory cat) {
    _draft = _draft.copyWith(category: cat);
    notifyListeners();
  }

  void updateDetails({required String title, required String description}) {
    _draft = _draft.copyWith(title: title, description: description);
    notifyListeners();
  }

  void addAttachment(String path) {
    final list = List<String>.from(_draft.attachments)..add(path);
    _draft = _draft.copyWith(attachments: list);
    notifyListeners();
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < _draft.attachments.length) {
      final list = List<String>.from(_draft.attachments)..removeAt(index);
      _draft = _draft.copyWith(attachments: list);
      notifyListeners();
    }
  }

  void updateLocation({
    required String address,
    required double lat,
    required double lng,
  }) {
    _draft = _draft.copyWith(
      locationAddress: address,
      latitude: lat,
      longitude: lng,
    );
    notifyListeners();
  }

  Future<Grievance?> submit() async {
    if (!_draft.isComplete || _isSubmitting) return null;

    _isSubmitting = true;
    _submissionError = null;
    notifyListeners();

    try {
      final result = await _service.submitGrievance(
        category: _draft.category!,
        title: _draft.title,
        description: _draft.description,
        locationAddress: _draft.locationAddress,
        latitude: _draft.latitude,
        longitude: _draft.longitude,
        attachments: _draft.attachments,
      );

      _lastSubmittedGrievance = result;
      // Reset draft after successful registration
      _draft = const GrievanceDraft();
      _isSubmitting = false;
      notifyListeners();
      return result;
    } catch (e) {
      _submissionError = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  void resetDraft() {
    _draft = const GrievanceDraft();
    _submissionError = null;
    notifyListeners();
  }

  Future<List<Grievance>> fetchMyGrievances() => _service.getMyGrievances();
  Future<Grievance?> fetchGrievanceById(String id) => _service.getGrievanceById(id);
  Future<List<Grievance>> fetchNearbyGrievances({GrievanceCategory? filter}) =>
      _service.getNearbyGrievances(filterCategory: filter);
}
