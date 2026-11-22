import 'package:flutter/foundation.dart';

class SavedAddressItem {
  const SavedAddressItem({
    required this.id,
    required this.label, // 'Home', 'Office', 'Other'
    required this.houseBuilding,
    required this.streetLocality,
    required this.districtCity,
    required this.state,
    required this.postalCode,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String houseBuilding;
  final String streetLocality;
  final String districtCity;
  final String state;
  final String postalCode;
  final bool isDefault;

  String get formattedAddress =>
      '$houseBuilding, $streetLocality, $districtCity, $state - $postalCode';

  SavedAddressItem copyWith({
    String? id,
    String? label,
    String? houseBuilding,
    String? streetLocality,
    String? districtCity,
    String? state,
    String? postalCode,
    bool? isDefault,
  }) {
    return SavedAddressItem(
      id: id ?? this.id,
      label: label ?? this.label,
      houseBuilding: houseBuilding ?? this.houseBuilding,
      streetLocality: streetLocality ?? this.streetLocality,
      districtCity: districtCity ?? this.districtCity,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class SavedAddressesController extends ChangeNotifier {
  SavedAddressesController() {
    _initSampleAddresses();
  }

  static final SavedAddressesController instance = SavedAddressesController();

  final List<SavedAddressItem> _addresses = [];

  List<SavedAddressItem> get addresses => List.unmodifiable(_addresses);

  void _initSampleAddresses() {
    if (_addresses.isNotEmpty) return;

    _addresses.addAll([
      const SavedAddressItem(
        id: 'addr-1',
        label: 'Home',
        houseBuilding: 'House No. 42',
        streetLocality: 'Sector 4, Near Gandhi Park',
        districtCity: 'Itanagar',
        state: 'Arunachal Pradesh',
        postalCode: '791111',
        isDefault: true,
      ),
      const SavedAddressItem(
        id: 'addr-2',
        label: 'Office',
        houseBuilding: 'Civil Secretariat Complex',
        streetLocality: 'Block B, Sector 12',
        districtCity: 'Itanagar',
        state: 'Arunachal Pradesh',
        postalCode: '791112',
        isDefault: false,
      ),
    ]);
  }

  void addAddress(SavedAddressItem item) {
    if (item.isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(item);
    notifyListeners();
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void setDefault(String id) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    notifyListeners();
  }
}
