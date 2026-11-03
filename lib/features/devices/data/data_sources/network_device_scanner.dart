import 'dart:async';
import 'dart:io';

import '../../domain/models/device.dart';

abstract interface class NetworkDeviceScanner {
  Future<List<Device>> scan();
}

class SocketNetworkDeviceScanner implements NetworkDeviceScanner {
  SocketNetworkDeviceScanner({
    this.ports = const [631, 9100, 515, 80, 443],
    this.timeout = const Duration(milliseconds: 350),
  });

  final List<int> ports;
  final Duration timeout;

  @override
  Future<List<Device>> scan() async {
    final hosts = await _localIpv4Hosts();
    final devices = <Device>[];
    for (var start = 0; start < hosts.length; start += 32) {
      final batch = hosts.skip(start).take(32);
      final batchDevices = await Future.wait(batch.map(_scanHost));
      devices.addAll(batchDevices.whereType<Device>());
    }
    return devices;
  }

  Future<Device?> _scanHost(String host) async {
    final openPorts = await _openPorts(host);
    if (openPorts.isEmpty) {
      return null;
    }

    final name = await _resolveName(host);
    final identity = name == host ? host : name;
    final normalizedIdentity = identity.toLowerCase();
    final type =
        normalizedIdentity.contains('plot') ||
            normalizedIdentity.contains('ejet')
        ? DeviceType.plotter
        : DeviceType.printer;
    return Device(
      id: 'network:$host',
      name: identity,
      type: type,
      connection: DeviceConnection.network,
      status: DeviceStatus.active,
      details: 'IP: $host; ports: ${openPorts.join(', ')}',
    );
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
