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
      _commandRunner.run('bluetoothctl', ['devices', 'Connected']),
      _commandRunner.run('pactl', ['list', 'sinks']),
      _commandRunner.run('pactl', ['list', 'sources']),
    ]);

    final printers = _parsePrinters(results[0].stdout);
    return [
      ...printers,
      ..._parseUsbDevices(results[1].stdout, printers),
      ..._parseBluetoothDevices(results[2].stdout, results[3].stdout),
      ..._parseAudioDevices(results[4].stdout, results[5].stdout),
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
          type: name.toLowerCase().contains('plot')
              ? DeviceType.plotter
              : DeviceType.printer,
          connection: _printerConnection(uri),
          status: description.contains('disabled')
              ? DeviceStatus.inactive
              : DeviceStatus.active,
          details: uri ?? description,
          connectionPort: uri == null ? null : _connectionPort(uri),
          vendor: _vendorFromUri(uri),
        ),
      );
    }
    return devices;
  }

  List<Device> _parseUsbDevices(String output, List<Device> printers) {
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
      if (_isUsbInfrastructure(name) || _isBluetoothController(name)) {
        continue;
      }
      final type =
          _classifyDevice(name) ??
          _configuredUsbPrinterType(name, printers) ??
          DeviceType.unknown;
      if (type != DeviceType.unknown &&
          _configuredUsbPrinterType(name, printers) != null) {
        continue;
      }
      devices.add(
        Device(
          id: 'usb:${trimmed.hashCode}',
          name: name,
          type: type,
          connection: DeviceConnection.usb,
          status: DeviceStatus.active,
          details: trimmed,
          vendor: _usbVendor(trimmed),
          connectionPort: _usbLocation(trimmed),
        ),
      );
    }
    return devices;
  }

  DeviceType? _configuredUsbPrinterType(String usbName, List<Device> printers) {
    final normalizedUsbName = usbName.toLowerCase();
    for (final printer in printers) {
      if (printer.connection != DeviceConnection.usb ||
          printer.details == null) {
        continue;
      }
      final uriTokens = printer.details!
          .replaceFirst(RegExp(r'^usb://'), '')
          .split(RegExp(r'[/?:=&\s]+'))
          .where((token) => token.length >= 3)
          .map((token) => token.toLowerCase());
      if (uriTokens.any(normalizedUsbName.contains)) {
        return printer.name.toLowerCase().contains('plot')
            ? DeviceType.plotter
            : DeviceType.printer;
      }
    }

    return null;
  }

  bool _isUsbInfrastructure(String name) {
    final normalizedName = name.toLowerCase();
    return _containsAny(normalizedName, [
      'hub',
      'root hub',
      'host controller',
      'linux foundation',
      'xhci',
      'ehci',
      'ohci',
      'uhci',
    ]);
  }

  bool _isBluetoothController(String name) {
    final normalizedName = name.toLowerCase();
    return _containsAny(normalizedName, [
      'bluetooth adapter',
      'bluetooth controller',
      'bluetooth radio',
      'wireless bluetooth',
      'ax201 bluetooth',
      'intel bluetooth',
      'realtek bluetooth',
      'broadcom bluetooth',
      'mediatek bluetooth',
      'qualcomm bluetooth',
    ]);
  }

  List<Device> _parseBluetoothDevices(String output, String connectedOutput) {
    final connectedIds = connectedOutput
        .split('\n')
        .where((line) => line.trim().startsWith('Device '))
        .map((line) => line.trim().split(RegExp(r'\s+'))[1])
        .toSet();

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
            type: _classifyDevice(name) ?? DeviceType.bluetooth,
            connection: DeviceConnection.bluetooth,
            status: connectedIds.contains(id)
                ? DeviceStatus.active
                : DeviceStatus.disconnected,
            details: id,
            connectionPort: id,
          );
        })
        .toList();
  }

  List<Device> _parseAudioDevices(String sinksOutput, String sourcesOutput) {
    return [
      ..._parseAudioPorts(
        sinksOutput,
        sectionPattern: RegExp(r'^Sink #'),
        deviceType: DeviceType.headset,
        portPattern: RegExp(
          r'\[Out\]\s+(Headphones|Headset)\b',
          caseSensitive: false,
        ),
        excludedNamePattern: RegExp(r'\.monitor\b', caseSensitive: false),
      ),
      ..._parseAudioPorts(
        sourcesOutput,
        sectionPattern: RegExp(r'^Source #'),
        deviceType: DeviceType.microphone,
        portPattern: RegExp(
          r'\[In\]\s+(Headset|Headset Microphone|Microphone|Mic)\b',
          caseSensitive: false,
        ),
        excludedNamePattern: RegExp(r'\.monitor\b', caseSensitive: false),
      ),
    ];
  }

  List<Device> _parseAudioPorts(
    String output, {
    required RegExp sectionPattern,
    required DeviceType deviceType,
    required RegExp portPattern,
    required RegExp excludedNamePattern,
  }) {
    final devices = <Device>[];
    final sections = output.split('\n');
    var section = <String>[];

    void addSection() {
      if (section.isEmpty) {
        return;
      }
      final name = _audioField(section, 'Name');
      final description = _audioField(section, 'Description');
      final availablePort = section.where(
        (line) =>
            line.contains('available') &&
            portPattern.hasMatch(line) &&
            !line.contains('not available'),
      );
      if (name == null ||
          description == null ||
          excludedNamePattern.hasMatch(name) ||
          availablePort.isEmpty) {
        return;
      }

      final portLine = availablePort.first;
      final portName = portPattern.firstMatch(portLine)?.group(1);
      devices.add(
        Device(
          id: 'audio:$name',
          name: description,
          type: deviceType,
          connection: DeviceConnection.audioJack,
          status: DeviceStatus.active,
          details: portName ?? portLine.trim(),
          connectionPort: portName,
        ),
      );
    }

    for (final line in sections) {
      if (sectionPattern.hasMatch(line)) {
        addSection();
        section = [line];
      } else if (section.isNotEmpty) {
        section.add(line);
      }
    }

    addSection();
    return devices;
  }

  String? _audioField(List<String> section, String field) {
    final prefix = RegExp('^\\s*$field:\\s*(.+)\$');
    for (final line in section) {
      final match = prefix.firstMatch(line);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  DeviceType? _classifyDevice(String name) {
    final normalizedName = name.toLowerCase();
    if (_containsAny(normalizedName, ['plotter', 'plot'])) {
      return DeviceType.plotter;
    }
    if (_containsAny(normalizedName, ['printer', 'print'])) {
      return DeviceType.printer;
    }
    if (_containsAny(normalizedName, ['monitor', 'display', 'screen'])) {
      return DeviceType.monitor;
    }
    if (_containsAny(normalizedName, [
      'headset',
      'headphone',
      'earbud',
      'auricular',
    ])) {
      return DeviceType.headset;
    }
    if (_containsAny(normalizedName, ['microphone', 'mic'])) {
      return DeviceType.microphone;
    }
    if (_containsAny(normalizedName, ['mouse', 'raton', 'ratón'])) {
      return DeviceType.mouse;
    }
    if (_containsAny(normalizedName, ['keyboard', 'teclado'])) {
      return DeviceType.keyboard;
    }
    if (_containsAny(normalizedName, ['camera', 'webcam'])) {
      return DeviceType.camera;
    }
    if (_containsAny(normalizedName, ['phone', 'mobile', 'galaxy', 'iphone'])) {
      return DeviceType.phone;
    }
    if (_containsAny(normalizedName, ['drive', 'storage', 'disk'])) {
      return DeviceType.storage;
    }
    return null;
  }

  bool _containsAny(String value, List<String> candidates) {
    return candidates.any(value.contains);
  }

  DeviceConnection _printerConnection(String? uri) {
    if (uri == null) return DeviceConnection.unknown;
    if (uri.startsWith('usb:')) return DeviceConnection.usb;
    if (uri.startsWith('ipp:') || uri.startsWith('http:')) {
      return DeviceConnection.network;
    }
    return DeviceConnection.local;
  }

  String? _connectionPort(String uri) {
    final scheme = uri.split(':').first;
    return scheme.isEmpty ? null : scheme.toUpperCase();
  }

  String? _vendorFromUri(String? uri) {
    if (uri == null) return null;
    final value = uri.replaceFirst(RegExp(r'^[a-z]+://'), '');
    final vendor = value.split(RegExp(r'[/?:]')).first.trim();
    return vendor.isEmpty ? null : vendor;
  }

  String? _usbVendor(String line) {
    final match = RegExp(r'\bID\s+\S+\s+(.+)$').firstMatch(line);
    final name = match?.group(1)?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  String? _usbLocation(String line) {
    final match = RegExp(r'^(Bus\s+\S+\s+Device\s+\S+:?)').firstMatch(line);
    return match?.group(1)?.replaceAll(':', '');
  }
}
