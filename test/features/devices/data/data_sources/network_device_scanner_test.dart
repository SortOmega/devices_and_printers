import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/features/devices/data/data_sources/network_device_scanner.dart';
import 'package:devices_and_printers/features/devices/domain/models/device.dart';

void main() {
  test('classifies a default gateway with only web ports as a router', () {
    final classification = classifyNetworkDevice(
      identity: '_gateway',
      openPorts: [80, 443],
      gateway: '192.168.101.1',
      host: '192.168.101.1',
    );

    expect(classification.type, DeviceType.router);
    expect(classification.confidence, 'high');
  });

  test('does not classify a web-only host as a printer', () {
    final classification = classifyNetworkDevice(
      identity: 'unknown-host',
      openPorts: [80, 443],
      gateway: '192.168.101.1',
      host: '192.168.101.26',
    );

    expect(classification.type, DeviceType.networkDevice);
    expect(classification.confidence, 'low');
  });

  test('requires a printing service for printer classification', () {
    final classification = classifyNetworkDevice(
      identity: 'office-printer',
      openPorts: [80],
      gateway: null,
      host: '192.168.101.26',
    );

    expect(classification.type, DeviceType.networkDevice);
  });

  test('network scanner contract exposes discovered network devices', () async {
    final scanner = FakeNetworkDeviceScanner([
      const Device(
        id: 'network:196.12.0.188',
        name: 'Ejet-1902',
        type: DeviceType.plotter,
        connection: DeviceConnection.network,
        status: DeviceStatus.active,
        details: 'IP: 196.12.0.188; ports: 9100',
      ),
    ]);

    final devices = await scanner.scan();

    expect(devices, hasLength(1));
    expect(devices.single.connection, DeviceConnection.network);
    expect(devices.single.type, DeviceType.plotter);
    expect(devices.single.details, contains('196.12.0.188'));
  });
}

class FakeNetworkDeviceScanner implements NetworkDeviceScanner {
  FakeNetworkDeviceScanner(this.devices);

  final List<Device> devices;

  @override
  Future<List<Device>> scan() async => devices;
}
