import 'package:flutter_test/flutter_test.dart';

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
}
