import '../data_sources/system_command_runner.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';

class SystemDeviceRepository implements DeviceRepository {
  SystemDeviceRepository({SystemCommandRunner? commandRunner})
    : _commandRunner = commandRunner ?? ProcessSystemCommandRunner();

  final SystemCommandRunner _commandRunner;

  @override
  Future<List<Device>> getDevices() async {
    final results = await Future.wait([
      _commandRunner.run('lpstat', ['-p', '-v']),
      _commandRunner.run('lsusb', const []),
      _commandRunner.run('bluetoothctl', ['devices']),
    ]);

    return [
      ..._parsePrinters(results[0].stdout),
      ..._parseUsbDevices(results[1].stdout),
      ..._parseBluetoothDevices(results[2].stdout),
    ];
  }

  List<Device> _parsePrinters(String output) {
    final devices = <Device>[];
    final printerPattern = RegExp(r'^printer\s+(\S+)\s+(.+)$');
    final connectionPattern = RegExp(r'^device for\s+(\S+):\s+(\S+)$');
    final connections = <String, String>{};
    final printers = <String, String>{};

    for (final line in output.split('\n')) {
      final connection = connectionPattern.firstMatch(line.trim());
      if (connection != null) {
        connections[connection.group(1)!] = connection.group(2)!;
        continue;
      }

      final printer = printerPattern.firstMatch(line.trim());
      if (printer == null) {
        continue;
      }

      printers[printer.group(1)!] = printer.group(2)!;
    }

    for (final entry in printers.entries) {
      final name = entry.key;
      final description = entry.value;
      final uri = connections[name];
      devices.add(
        Device(
          id: 'printer:$name',
          name: name,
          type: DeviceType.printer,
          connection: _printerConnection(uri),
          status: description.contains('disabled')
              ? DeviceStatus.unavailable
              : DeviceStatus.recognized,
          details: uri ?? description,
        ),
      );
    }
    return devices;
  }

  List<Device> _parseUsbDevices(String output) {
    final devices = <Device>[];
    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final name = trimmed.replaceFirst(
        RegExp(r'^Bus\s+\S+\s+Device\s+\S+:\s+ID\s+\S+\s+\S+\s+'),
        '',
      );
      devices.add(
        Device(
          id: 'usb:${trimmed.hashCode}',
          name: name,
          type: DeviceType.usb,
          connection: DeviceConnection.usb,
          status: DeviceStatus.recognized,
          details: trimmed,
        ),
      );
    }
    return devices;
  }

  List<Device> _parseBluetoothDevices(String output) {
    return output
        .split('\n')
        .where((line) => line.trim().startsWith('Device '))
        .map((line) {
          final parts = line.trim().split(RegExp(r'\s+'));
          final id = parts.length > 1 ? parts[1] : line.hashCode.toString();
          final name = parts.length > 2 ? parts.sublist(2).join(' ') : id;
          return Device(
            id: 'bluetooth:$id',
            name: name,
            type: DeviceType.bluetooth,
            connection: DeviceConnection.bluetooth,
            status: DeviceStatus.recognized,
            details: id,
          );
        })
        .toList();
  }

  DeviceConnection _printerConnection(String? uri) {
    if (uri == null) return DeviceConnection.unknown;
    if (uri.startsWith('usb:')) return DeviceConnection.usb;
    if (uri.startsWith('ipp:') || uri.startsWith('http:')) {
      return DeviceConnection.network;
    }
    return DeviceConnection.local;
  }
}
