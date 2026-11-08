import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/core/network/network_scan_settings.dart';

void main() {
  test('uses automatic network scanning by default', () async {
    final settings = NetworkScanSettings(_FakeStorage());

    await settings.initialize();

    expect(settings.automaticScan, isTrue);
  });

  test('persists the automatic network scanning preference', () async {
    final storage = _FakeStorage()..value = true;
    final settings = NetworkScanSettings(storage);
    await settings.initialize();

    await settings.setAutomaticScan(false);

    expect(settings.automaticScan, isFalse);
    expect(storage.value, isFalse);
  });
}

class _FakeStorage implements NetworkScanSettingsStorage {
  bool? value;

  @override
  Future<bool?> readAutomaticScan() async => value;

  @override
  Future<void> writeAutomaticScan(bool value) async {
    this.value = value;
  }
}
