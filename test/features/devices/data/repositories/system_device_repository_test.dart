import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/features/devices/data/data_sources/system_command_runner.dart';
import 'package:devices_and_printers/features/devices/data/repositories/system_device_repository.dart';
import 'package:devices_and_printers/features/devices/domain/models/device.dart';

class FakeCommandRunner implements SystemCommandRunner {
  FakeCommandRunner(this.results);

  final Map<String, CommandResult> results;

  @override
  Future<CommandResult> run(String command, List<String> arguments) async {
    return results[command] ??
        const CommandResult(stdout: '', stderr: '', exitCode: 0);
  }
}

void main() {
  test('parses printers, USB devices, and Bluetooth devices', () async {
    final repository = SystemDeviceRepository(
      commandRunner: FakeCommandRunner({
        'lpstat': const CommandResult(
          stdout:
              'printer Office_Printer is idle. enabled since today\n'
              'device for Office_Printer: ipp://192.168.1.20/printers/office\n',
          stderr: '',
          exitCode: 0,
        ),
        'lsusb': const CommandResult(
          stdout: 'Bus 001 Device 002: ID 1234:5678 Example Keyboard\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl': const CommandResult(
          stdout: 'Device AA:BB:CC:DD:EE:FF Wireless Headphones\n',
          stderr: '',
          exitCode: 0,
        ),
      }),
    );

    final devices = await repository.getDevices();

    expect(devices, hasLength(3));
    expect(devices.where((device) => device.isPrinter), hasLength(1));
    expect(devices[0].connection, DeviceConnection.network);
    expect(devices[1].type, DeviceType.usb);
    expect(devices[2].type, DeviceType.bluetooth);
  });
}
