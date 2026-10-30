import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/features/devices/data/data_sources/system_command_runner.dart';
import 'package:devices_and_printers/features/devices/data/repositories/system_device_repository.dart';
import 'package:devices_and_printers/features/devices/domain/models/device.dart';

class FakeCommandRunner implements SystemCommandRunner {
  FakeCommandRunner(this.results);

  final Map<String, CommandResult> results;

  @override
  Future<CommandResult> run(String command, List<String> arguments) async {
    return results['$command ${arguments.join(' ')}'] ??
        results[command] ??
        const CommandResult(stdout: '', stderr: '', exitCode: 0);
  }
}

void main() {
  test('parses known devices and filters generic USB entries', () async {
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
          stdout:
              'Bus 001 Device 002: ID 1234:5678 Example Keyboard\n'
              'Bus 001 Device 003: ID 2345:6789 Generic USB Hub\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices': const CommandResult(
          stdout: 'Device AA:BB:CC:DD:EE:FF Wireless Headphones\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices Connected': const CommandResult(
          stdout: '',
          stderr: '',
          exitCode: 0,
        ),
      }),
    );

    final devices = await repository.getDevices();

    expect(devices, hasLength(3));
    expect(devices.where((device) => device.isPrinter), hasLength(1));
    expect(devices[0].connection, DeviceConnection.network);
    expect(devices[1].type, DeviceType.keyboard);
    expect(devices[1].status, DeviceStatus.active);
    expect(devices[2].type, DeviceType.headset);
    expect(devices[2].status, DeviceStatus.disconnected);
  });
}
