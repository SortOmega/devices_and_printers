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
  test(
    'uses CUPS description as printer name and queue name as fallback',
    () async {
      final repository = SystemDeviceRepository(
        commandRunner: FakeCommandRunner({
          'lpstat': const CommandResult(
            stdout:
                'printer GuanDong is idle. enabled since today\n'
                '  Device URI: socket://192.168.1.20:9100\n'
                'printer PLOTTER-GCC-AR24 is idle. enabled since today\n'
                '  Device URI: usb://GCC/AR-24?serial=0.0\n',
            stderr: '',
            exitCode: 0,
          ),
          'lpstat -l -p GuanDong': const CommandResult(
            stdout:
                'printer GuanDong is idle.\n'
                '\tDescription: GuangDong KY EjEt 1902\n',
            stderr: '',
            exitCode: 0,
          ),
          'lpstat -l -p PLOTTER-GCC-AR24': const CommandResult(
            stdout:
                'printer PLOTTER-GCC-AR24 is idle.\n'
                '\tDescription:    \n',
            stderr: '',
            exitCode: 0,
          ),
          'lsusb': const CommandResult(stdout: '', stderr: '', exitCode: 0),
          'bluetoothctl devices': const CommandResult(
            stdout: '',
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

      expect(devices, hasLength(2));
      final printer = devices.singleWhere(
        (device) => device.id == 'printer:GuanDong',
      );
      expect(printer.name, 'GuangDong KY EjEt 1902');
      expect(printer.additionalDetails['queueName'], 'GuanDong');
      expect(
        printer.additionalDetails['description'],
        'GuangDong KY EjEt 1902',
      );

      final plotter = devices.singleWhere(
        (device) => device.id == 'printer:PLOTTER-GCC-AR24',
      );
      expect(plotter.name, 'PLOTTER-GCC-AR24');
    },
  );

  test(
    'classifies Bluetooth devices by their real type and merges matching ports',
    () async {
      final repository = SystemDeviceRepository(
        commandRunner: FakeCommandRunner({
          'lpstat': const CommandResult(stdout: '', stderr: '', exitCode: 0),
          'lsusb': const CommandResult(
            stdout: 'Bus 001 Device 010: ID 054c:0ce6 Corp. DualSense wireless controller\n',
            stderr: '',
            exitCode: 0,
          ),
          'bluetoothctl devices': const CommandResult(
            stdout:
                'Device AA:BB:CC:DD:EE:10 DualSense Wireless Controller\n'
                'Device AA:BB:CC:DD:EE:11 Living Room Speaker\n',
            stderr: '',
            exitCode: 0,
          ),
          'bluetoothctl devices Connected': const CommandResult(
            stdout: 'Device AA:BB:CC:DD:EE:10 DualSense Wireless Controller\n',
            stderr: '',
            exitCode: 0,
          ),
          'bluetoothctl info AA:BB:CC:DD:EE:10': const CommandResult(
            stdout:
                'Device AA:BB:CC:DD:EE:10 (AA:BB:CC:DD:EE:10)\n'
                '\tName: DualSense Wireless Controller\n'
                '\tIcon: input-gaming\n'
                '\tClass: 0x000005\n',
            stderr: '',
            exitCode: 0,
          ),
          'bluetoothctl info AA:BB:CC:DD:EE:11': const CommandResult(
            stdout:
                'Device AA:BB:CC:DD:EE:11 (AA:BB:CC:DD:EE:11)\n'
                '\tName: Living Room Speaker\n'
                '\tIcon: audio-card\n'
                '\tClass: 0x000414\n',
            stderr: '',
            exitCode: 0,
          ),
        }),
      );

      final devices = await repository.getDevices();

      expect(devices, hasLength(2));
      final controller = devices.singleWhere(
        (device) => device.name.contains('DualSense'),
      );
      expect(controller.type, DeviceType.gameConsole);
      expect(controller.connection, DeviceConnection.usb);
      expect(controller.hasBluetoothConnection, isTrue);
      expect(controller.components, hasLength(2));

      final speaker = devices.singleWhere(
        (device) => device.name == 'Living Room Speaker',
      );
      expect(speaker.type, DeviceType.speaker);
      expect(speaker.connection, DeviceConnection.bluetooth);
    },
  );

  test('classifies common USB game consoles', () async {
    final repository = SystemDeviceRepository(
      commandRunner: FakeCommandRunner({
        'lpstat': const CommandResult(stdout: '', stderr: '', exitCode: 0),
        'lsusb': const CommandResult(
          stdout:
              'Bus 001 Device 010: ID 054c:0ce6 Sony PlayStation 5\n'
              'Bus 001 Device 011: ID 045e:02ea Microsoft Xbox Controller\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices': const CommandResult(
          stdout: '',
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

    expect(devices, hasLength(2));
    expect(
      devices.every((device) => device.type == DeviceType.gameConsole),
      isTrue,
    );
  });

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
              'Bus 001 Device 003: ID 2345:6789 Generic USB Hub\n'
              'Bus 001 Device 004: ID 1d6b:0002 Linux Foundation 2.0 root hub\n'
              'Bus 001 Device 005: ID 8087:0026 Corp. AX201 Bluetooth\n',
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
    expect(devices[1].vendor, 'Example');
    expect(devices[1].connectionPort, 'Bus 001 Device 002');
    expect(devices[2].type, DeviceType.headset);
    expect(devices[2].status, DeviceStatus.disconnected);
  });

  test('filters the built-in Bluetooth controller', () async {
    final repository = SystemDeviceRepository(
      commandRunner: FakeCommandRunner({
        'lpstat': const CommandResult(stdout: '', stderr: '', exitCode: 0),
        'lsusb': const CommandResult(
          stdout: 'Bus 001 Device 005: ID 8087:0026 Corp. AX201 Bluetooth\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices': const CommandResult(
          stdout: '',
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

    expect(devices, isEmpty);
  });

  test('recognizes a USB plotter without a configured driver', () async {
    final repository = SystemDeviceRepository(
      commandRunner: FakeCommandRunner({
        'lpstat': const CommandResult(stdout: '', stderr: '', exitCode: 0),
        'lsusb': const CommandResult(
          stdout: 'Bus 001 Device 004: ID 1234:5678 Large Format Plotter\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices': const CommandResult(
          stdout: '',
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

    expect(devices, hasLength(1));
    expect(devices.single.type, DeviceType.plotter);
    expect(devices.single.status, DeviceStatus.active);
    expect(devices.single.connection, DeviceConnection.usb);
    expect(devices.single.connectionPort, 'Bus 001 Device 004');
  });

  test('uses the configured CUPS printer for its USB identity', () async {
    final repository = SystemDeviceRepository(
      commandRunner: FakeCommandRunner({
        'lpstat': const CommandResult(
          stdout:
              'printer PLOTTER-GCC-AR24 is idle. enabled since today\n'
              'device for PLOTTER-GCC-AR24: usb://GCC/AR-24?serial=0.0\n',
          stderr: '',
          exitCode: 0,
        ),
        'lsusb': const CommandResult(
          stdout: 'Bus 003 Device 005: ID 0f0b:801a GCC AR-24\n',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices': const CommandResult(
          stdout: '',
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

    expect(devices, hasLength(1));
    expect(devices.single.name, 'PLOTTER-GCC-AR24');
    expect(devices.single.type, DeviceType.plotter);
    expect(devices.single.connection, DeviceConnection.usb);
  });

  test('detects available headphones and jack microphones', () async {
    final repository = SystemDeviceRepository(
      commandRunner: FakeCommandRunner({
        'lpstat': const CommandResult(stdout: '', stderr: '', exitCode: 0),
        'lsusb': const CommandResult(stdout: '', stderr: '', exitCode: 0),
        'bluetoothctl devices': const CommandResult(
          stdout: '',
          stderr: '',
          exitCode: 0,
        ),
        'bluetoothctl devices Connected': const CommandResult(
          stdout: '',
          stderr: '',
          exitCode: 0,
        ),
        'pactl list sinks': const CommandResult(
          stdout:
              'Sink #12\n'
              '\tName: alsa_output.pci.Headphones_sink\n'
              '\tDescription: Built-in Audio Headphones\n'
              '\tPorts:\n'
              '\t\t[Out] Headphones: Headphones (available)\n'
              '\tActive Port: [Out] HDMI\n'
              'Sink #13\n'
              '\tName: alsa_output.pci.HDMI_sink\n'
              '\tDescription: HDMI Output\n'
              '\tPorts:\n'
              '\t\t[Out] HDMI: HDMI (available)\n'
              '\tActive Port: [Out] HDMI\n',
          stderr: '',
          exitCode: 0,
        ),
        'pactl list sources': const CommandResult(
          stdout:
              'Source #14\n'
              '\tName: alsa_input.pci.Headset_source\n'
              '\tDescription: Built-in Audio Headset Microphone\n'
              '\tPorts:\n'
              '\t\t[In] Headset: Headset (available)\n'
              '\tActive Port: [In] Headset\n'
              'Source #15\n'
              '\tName: alsa_input.pci.Digital_source\n'
              '\tDescription: Built-in Digital Microphone\n'
              '\tPorts:\n'
              '\t\t[In] Mic1: Mic1 (available)\n'
              '\tActive Port: [In] Mic1\n',
          stderr: '',
          exitCode: 0,
        ),
      }),
    );

    final devices = await repository.getDevices();

    expect(devices, hasLength(1));
    expect(devices.single.type, DeviceType.headset);
    expect(devices.single.components, hasLength(2));
    expect(
      devices.single.components.where(
        (component) => component.type == DeviceType.headset,
      ),
      hasLength(1),
    );
    expect(
      devices.single.components.where(
        (component) => component.type == DeviceType.microphone,
      ),
      hasLength(1),
    );
    expect(
      devices.every((device) => device.status == DeviceStatus.active),
      isTrue,
    );
    expect(
      devices.every(
        (device) => device.connection == DeviceConnection.audioJack,
      ),
      isTrue,
    );
  });
}
