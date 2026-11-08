import 'dart:async';
import 'dart:io';

import 'system_command_runner.dart';
import '../../domain/models/device.dart';

abstract interface class NetworkDeviceScanner {
  Future<List<Device>> scan();
}

class NetworkDeviceClassification {
  const NetworkDeviceClassification({
    required this.type,
    required this.confidence,
  });

  final DeviceType type;
  final String confidence;
}

NetworkDeviceClassification classifyNetworkDevice({
  required String identity,
  required List<int> openPorts,
  required String? gateway,
  required String host,
}) {
  final normalizedIdentity = identity.toLowerCase();
  final hasPrintingService = openPorts.any(
    (port) => port == 631 || port == 9100 || port == 515,
  );
  final looksLikeRouter =
      host == gateway || _containsRouterSignal(normalizedIdentity);
  final type = hasPrintingService
      ? (normalizedIdentity.contains('plot') ||
                normalizedIdentity.contains('ejet')
            ? DeviceType.plotter
            : DeviceType.printer)
      : looksLikeRouter
      ? DeviceType.router
      : DeviceType.networkDevice;
  final confidence = hasPrintingService || host == gateway
      ? 'high'
      : looksLikeRouter
      ? 'medium'
      : 'low';
  return NetworkDeviceClassification(type: type, confidence: confidence);
}

bool _containsRouterSignal(String identity) {
  return [
    'gateway',
    'router',
    'repeater',
    'extender',
    'access point',
    'accesspoint',
    'openwrt',
    'mikrotik',
    'tp-link',
    'tplink',
    'netgear',
    'ubiquiti',
    'asus',
    'd-link',
    'dlink',
  ].any(identity.contains);
}

class SocketNetworkDeviceScanner implements NetworkDeviceScanner {
  SocketNetworkDeviceScanner({
    this.ports = const [631, 9100, 515, 80, 443],
    this.timeout = const Duration(milliseconds: 350),
    SystemCommandRunner? commandRunner,
  }) : _commandRunner = commandRunner ?? ProcessSystemCommandRunner();

  final List<int> ports;
  final Duration timeout;
  final SystemCommandRunner _commandRunner;

  @override
  Future<List<Device>> scan() async {
    final hosts = await _localIpv4Hosts();
    final gateway = await _defaultGateway();
    final devices = <Device>[];
    for (var start = 0; start < hosts.length; start += 32) {
      final batch = hosts.skip(start).take(32);
      final batchDevices = await Future.wait(
        batch.map((host) => _scanHost(host, gateway)),
      );
      devices.addAll(batchDevices.whereType<Device>());
    }
    return devices;
  }

  Future<Device?> _scanHost(String host, String? gateway) async {
    final openPorts = await _openPorts(host);
    if (openPorts.isEmpty) {
      return null;
    }

    final name = await _resolveName(host);
    final identity = name == host ? host : name;
    final classification = classifyNetworkDevice(
      identity: identity,
      openPorts: openPorts,
      gateway: gateway,
      host: host,
    );
    final additionalDetails = <String, String>{
      'classification': classification.type.name,
      'confidence': classification.confidence,
    };
    if (gateway != null) {
      additionalDetails['defaultGateway'] = gateway;
    }
    return Device(
      id: 'network:$host',
      name: identity,
      type: classification.type,
      connection: DeviceConnection.network,
      status: DeviceStatus.active,
      details: 'IP: $host; ports: ${openPorts.join(', ')}',
      connectionPort: openPorts.join(', '),
      vendor: name == host ? null : name.split(RegExp(r'[\s.-]')).first,
      additionalDetails: additionalDetails,
    );
  }

  Future<String?> _defaultGateway() async {
    final result = await _commandRunner.run('ip', ['route', 'show', 'default']);
    if (result.exitCode != 0) return null;
    final match = RegExp(r'\bvia\s+(\d{1,3}(?:\.\d{1,3}){3})\b')
        .firstMatch(result.stdout);
    return match?.group(1);
  }

  Future<List<String>> _localIpv4Hosts() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      final hosts = <String>{};
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final octets = address.address.split('.');
          if (octets.length != 4) {
            continue;
          }
          final prefix = octets.take(3).join('.');
          for (var lastOctet = 1; lastOctet < 255; lastOctet++) {
            final host = '$prefix.$lastOctet';
            if (host != address.address) {
              hosts.add(host);
            }
          }
        }
      }
      return hosts.toList()..sort();
    } on SocketException {
      return const [];
    }
  }

  Future<List<int>> _openPorts(String host) async {
    final results = await Future.wait(
      ports.map((port) async {
        try {
          final socket = await Socket.connect(host, port, timeout: timeout);
          socket.destroy();
          return port;
        } on SocketException {
          return null;
        } on TimeoutException {
          return null;
        }
      }),
    );
    return results.whereType<int>().toList()..sort();
  }

  Future<String> _resolveName(String host) async {
    try {
      final address = await InternetAddress(host).reverse();
      return address.host;
    } on SocketException {
      return host;
    }
  }
}
