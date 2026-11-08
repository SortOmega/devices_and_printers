import 'package:flutter/foundation.dart';

abstract interface class NetworkScanSettingsStorage {
  Future<bool?> readAutomaticScan();
  Future<void> writeAutomaticScan(bool value);
}

class NetworkScanSettings extends ChangeNotifier {
  NetworkScanSettings(this._storage);

  final NetworkScanSettingsStorage _storage;
  bool _automaticScan = true;

  bool get automaticScan => _automaticScan;

  Future<void> initialize() async {
    _automaticScan = await _storage.readAutomaticScan() ?? true;
    notifyListeners();
  }

  Future<void> setAutomaticScan(bool enabled) async {
    if (_automaticScan == enabled) return;
    _automaticScan = enabled;
    await _storage.writeAutomaticScan(enabled);
    notifyListeners();
  }
}
