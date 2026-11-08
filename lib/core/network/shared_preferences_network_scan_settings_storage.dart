import 'package:shared_preferences/shared_preferences.dart';

import 'network_scan_settings.dart';

class SharedPreferencesNetworkScanSettingsStorage
    implements NetworkScanSettingsStorage {
  SharedPreferencesNetworkScanSettingsStorage(this._preferences);

  static const _automaticScanKey = 'network_automatic_scan';
  final SharedPreferences _preferences;

  @override
  Future<bool?> readAutomaticScan() async {
    return _preferences.getBool(_automaticScanKey);
  }

  @override
  Future<void> writeAutomaticScan(bool value) async {
    await _preferences.setBool(_automaticScanKey, value);
  }
}
