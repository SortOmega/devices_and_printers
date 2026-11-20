import 'package:devices_and_printers/features/devices/data/data_sources/device_cache.dart';
import 'package:devices_and_printers/features/devices/domain/models/device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists and restores local devices and components', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final cache = DeviceCache(preferences);

    await cache.save(const [
      Device(
        id: 'audio:headset',
        name: 'Test headset',
        type: DeviceType.headset,
        connection: DeviceConnection.audioJack,
        status: DeviceStatus.active,
        vendor: 'Test vendor',
        components: [
          DeviceComponent(
            id: 'audio:sink',
            name: 'Output',
            type: DeviceType.headset,
            connection: DeviceConnection.audioJack,
            status: DeviceStatus.active,
            connectionPort: 'Headphones',
          ),
        ],
      ),
      Device(
        id: 'network:router',
        name: 'Router',
        type: DeviceType.router,
        connection: DeviceConnection.network,
        status: DeviceStatus.active,
      ),
    ]);

    final restored = cache.load();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'audio:headset');
    expect(restored.single.components.single.id, 'audio:sink');
  });

  test('returns no devices for invalid cache data', () async {
    SharedPreferences.setMockInitialValues({
      DeviceCache.storageKey: '{invalid',
    });
    final preferences = await SharedPreferences.getInstance();

    expect(DeviceCache(preferences).load(), isEmpty);
  });
}
