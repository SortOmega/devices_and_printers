import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/device.dart';

class DeviceCache {
  DeviceCache(this._preferences);

  static const String storageKey = 'cached_local_devices';
  final SharedPreferences _preferences;

  List<Device> load() {
    final encodedDevices = _preferences.getString(storageKey);
    if (encodedDevices == null || encodedDevices.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(encodedDevices);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((device) => _deviceFromJson(device))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<Device> devices) {
    final localDevices = devices
        .where((device) => device.connection != DeviceConnection.network)
        .toList();
    final encodedDevices = jsonEncode(localDevices.map(_deviceToJson).toList());
    return _preferences.setString(storageKey, encodedDevices);
  }

  Map<String, Object?> _deviceToJson(Device device) {
    return {
      'id': device.id,
      'name': device.name,
      'type': device.type.name,
      'status': device.status.name,
      'connection': device.connection.name,
      'details': device.details,
      'vendor': device.vendor,
      'connectionPort': device.connectionPort,
      'additionalDetails': device.additionalDetails,
      'components': device.components.map((component) {
        return {
          'id': component.id,
          'name': component.name,
          'type': component.type.name,
          'status': component.status.name,
          'connection': component.connection.name,
          'details': component.details,
          'vendor': component.vendor,
          'connectionPort': component.connectionPort,
          'additionalDetails': component.additionalDetails,
        };
      }).toList(),
    };
  }

  Device _deviceFromJson(Map deviceJson) {
    final additionalDetails = _stringMap(deviceJson['additionalDetails']);
    final componentsJson = deviceJson['components'];
    final components = componentsJson is List
        ? componentsJson
              .whereType<Map>()
              .map((component) => _componentFromJson(component))
              .toList()
        : const <DeviceComponent>[];
    return Device(
      id: deviceJson['id']?.toString() ?? '',
      name: deviceJson['name']?.toString() ?? '',
      type: _deviceType(deviceJson['type']),
      status: _deviceStatus(deviceJson['status']),
      connection: _deviceConnection(deviceJson['connection']),
      details: deviceJson['details']?.toString(),
      vendor: deviceJson['vendor']?.toString(),
      connectionPort: deviceJson['connectionPort']?.toString(),
      additionalDetails: additionalDetails,
      components: components,
    );
  }

  DeviceComponent _componentFromJson(Map componentJson) {
    return DeviceComponent(
      id: componentJson['id']?.toString() ?? '',
      name: componentJson['name']?.toString() ?? '',
      type: _deviceType(componentJson['type']),
      status: _deviceStatus(componentJson['status']),
      connection: _deviceConnection(componentJson['connection']),
      details: componentJson['details']?.toString(),
      vendor: componentJson['vendor']?.toString(),
      connectionPort: componentJson['connectionPort']?.toString(),
      additionalDetails: _stringMap(componentJson['additionalDetails']),
    );
  }

  Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        entry.key.toString(): entry.value?.toString() ?? '',
    };
  }

  DeviceType _deviceType(Object? value) {
    return DeviceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => DeviceType.unknown,
    );
  }

  DeviceStatus _deviceStatus(Object? value) {
    return DeviceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DeviceStatus.disconnected,
    );
  }

  DeviceConnection _deviceConnection(Object? value) {
    return DeviceConnection.values.firstWhere(
      (connection) => connection.name == value,
      orElse: () => DeviceConnection.unknown,
    );
  }
}
