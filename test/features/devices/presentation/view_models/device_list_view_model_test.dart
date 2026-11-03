import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/features/devices/data/data_sources/network_device_scanner.dart';
import 'package:devices_and_printers/features/devices/domain/models/device.dart';
import 'package:devices_and_printers/features/devices/domain/repositories/device_repository.dart';
import 'package:devices_and_printers/features/devices/presentation/view_models/device_list_view_model.dart';

class FakeDeviceRepository implements DeviceRepository {
  FakeDeviceRepository(this.devices);

  final List<Device> devices;

  @override
  Future<List<Device>> getDevices() async => devices;
}

void main() {
  test('loads devices and groups them by type', () async {
    final viewModel = DeviceListViewModel(
      FakeDeviceRepository([
        const Device(
          id: 'printer:one',
          name: 'Office printer',
          type: DeviceType.printer,
          connection: DeviceConnection.network,
          status: DeviceStatus.active,
        ),
        const Device(
          id: 'usb:one',
          name: 'Keyboard',
          type: DeviceType.keyboard,
          connection: DeviceConnection.usb,
          status: DeviceStatus.active,
        ),
      ]),
    );

    await viewModel.loadDevices();

    expect(viewModel.status, DeviceListStatus.loaded);
    expect(viewModel.groupedDevices[DeviceType.printer], hasLength(1));
    expect(viewModel.groupedDevices[DeviceType.keyboard], hasLength(1));
  });

  test('loads local devices before the network scan completes', () async {
    final networkScan = Completer<List<Device>>();
    final viewModel = DeviceListViewModel(
      FakeDeviceRepository(const [
        Device(
          id: 'usb:one',
          name: 'Keyboard',
          type: DeviceType.keyboard,
          connection: DeviceConnection.usb,
          status: DeviceStatus.active,
        ),
      ]),
      FakeNetworkDeviceScanner(networkScan.future),
    );

    await viewModel.loadDevices();

    expect(viewModel.status, DeviceListStatus.loaded);
    expect(viewModel.devices, hasLength(1));
    expect(viewModel.isScanningNetwork, isTrue);

    networkScan.complete(const [
      Device(
        id: 'network:196.12.0.188',
        name: 'Ejet-1902',
        type: DeviceType.plotter,
        connection: DeviceConnection.network,
        status: DeviceStatus.active,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.devices, hasLength(2));
    expect(viewModel.devices.last.name, 'Ejet-1902');
    expect(viewModel.isScanningNetwork, isFalse);
  });
}

class FakeNetworkDeviceScanner implements NetworkDeviceScanner {
  FakeNetworkDeviceScanner(this.result);

  final Future<List<Device>> result;

  @override
  Future<List<Device>> scan() => result;
}
