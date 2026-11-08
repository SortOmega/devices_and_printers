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
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(viewModel.devices, hasLength(2));
    expect(viewModel.devices.last.name, 'Ejet-1902');
    expect(viewModel.isScanningNetwork, isFalse);
  });

  test(
    'refreshes only network devices and removes devices no longer found',
    () async {
      final firstScan = Completer<List<Device>>();
      final secondScan = Completer<List<Device>>();
      final scanner = QueuedNetworkDeviceScanner([
        firstScan.future,
        secondScan.future,
      ]);
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
        scanner,
      );

      await viewModel.loadDevices();
      firstScan.complete(const [
        Device(
          id: 'network:old',
          name: 'Old router',
          type: DeviceType.router,
          connection: DeviceConnection.network,
          status: DeviceStatus.active,
        ),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      unawaited(viewModel.refreshNetwork());
      expect(viewModel.devices, hasLength(2));
      secondScan.complete(const [
        Device(
          id: 'network:new',
          name: 'New router',
          type: DeviceType.router,
          connection: DeviceConnection.network,
          status: DeviceStatus.active,
        ),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.devices.map((device) => device.id), contains('usb:one'));
      expect(
        viewModel.devices.map((device) => device.id),
        contains('network:new'),
      );
      expect(
        viewModel.devices.map((device) => device.id),
        isNot(contains('network:old')),
      );
    },
  );

  test('cancelling a network refresh keeps existing devices', () async {
    final scan = Completer<List<Device>>();
    final viewModel = DeviceListViewModel(
      FakeDeviceRepository(const [
        Device(
          id: 'network:existing',
          name: 'Existing router',
          type: DeviceType.router,
          connection: DeviceConnection.network,
          status: DeviceStatus.active,
        ),
      ]),
      FakeNetworkDeviceScanner(scan.future),
    );

    await viewModel.loadDevices();
    viewModel.cancelNetworkScan();
    scan.complete(const []);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.isScanningNetwork, isFalse);
    expect(viewModel.devices.single.id, 'network:existing');
  });
}

class FakeNetworkDeviceScanner implements NetworkDeviceScanner {
  FakeNetworkDeviceScanner(this.result);

  final Future<List<Device>> result;

  @override
  Future<List<Device>> scan() => result;
}

class QueuedNetworkDeviceScanner implements NetworkDeviceScanner {
  QueuedNetworkDeviceScanner(this.results);

  final List<Future<List<Device>>> results;
  var _index = 0;

  @override
  Future<List<Device>> scan() => results[_index++];
}
