import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/network_scan_settings.dart';
import '../../data/data_sources/network_device_scanner.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';

enum DeviceListStatus { initial, loading, loaded, error }

class DeviceListViewModel extends ChangeNotifier {
  DeviceListViewModel(
    this._repository, [
    this._networkScanner,
    this._networkSettings,
    this._localRefreshInterval,
  ]) {
    _networkSettings?.addListener(_networkSettingsChanged);
    _networkSettingsChanged();
  }

  final DeviceRepository _repository;
  final NetworkDeviceScanner? _networkScanner;
  final NetworkScanSettings? _networkSettings;
  final Duration? _localRefreshInterval;
  DeviceListStatus status = DeviceListStatus.initial;
  List<Device> devices = const [];
  String? errorMessage;
  String? networkErrorMessage;
  bool isScanningNetwork = false;
  Timer? _automaticScanTimer;
  Timer? _localRefreshTimer;
  bool _isRefreshingLocalDevices = false;
  int _networkScanGeneration = 0;

  bool get canScanNetwork => _networkScanner != null;

  Future<void> loadDevices() async {
    cancelNetworkScan();
    status = DeviceListStatus.loading;
    errorMessage = null;
    networkErrorMessage = null;
    notifyListeners();
    try {
      devices = await _repository.getDevices();
      status = DeviceListStatus.loaded;
    } catch (error) {
      status = DeviceListStatus.error;
      errorMessage = error.toString();
    }
    notifyListeners();
    if (status == DeviceListStatus.loaded) {
      _startLocalMonitoring();
    }
    if (status == DeviceListStatus.loaded &&
        _networkSettings?.automaticScan != false) {
      refreshNetwork();
    }
  }

  void _startLocalMonitoring() {
    final interval = _localRefreshInterval;
    if (interval == null || _localRefreshTimer != null) return;
    _localRefreshTimer = Timer.periodic(
      interval,
      (_) => unawaited(_refreshLocalDevices()),
    );
  }

  Future<void> _refreshLocalDevices() async {
    if (_isRefreshingLocalDevices ||
        status != DeviceListStatus.loaded ||
        isScanningNetwork) {
      return;
    }
    _isRefreshingLocalDevices = true;
    try {
      final refreshedDevices = await _repository.getDevices();
      if (status != DeviceListStatus.loaded) return;
      final networkDevices = devices
          .where((device) => device.connection == DeviceConnection.network)
          .toList();
      final updatedDevices = [...refreshedDevices, ...networkDevices];
      if (_deviceListFingerprint(updatedDevices) !=
          _deviceListFingerprint(devices)) {
        devices = updatedDevices;
        notifyListeners();
      }
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    } finally {
      _isRefreshingLocalDevices = false;
    }
  }

  String _deviceListFingerprint(List<Device> values) {
    return values.map(_deviceFingerprint).join('|');
  }

  String _deviceFingerprint(Device device) {
    final components = device.components
        .map((component) {
          return [
            component.id,
            component.name,
            component.type.name,
            component.connection.name,
            component.status.name,
            component.details,
            component.vendor,
            component.connectionPort,
            ...component.additionalDetails.entries.map(
              (entry) => '${entry.key}=${entry.value}',
            ),
          ].join('\u0000');
        })
        .join('\u0001');
    return [
      device.id,
      device.name,
      device.type.name,
      device.connection.name,
      device.status.name,
      device.details,
      device.vendor,
      device.connectionPort,
      components,
      ...device.additionalDetails.entries.map(
        (entry) => '${entry.key}=${entry.value}',
      ),
    ].join('\u0000');
  }

  Future<void> refreshNetwork() async {
    if (_networkScanner == null || isScanningNetwork) return;
    final scanGeneration = ++_networkScanGeneration;
    isScanningNetwork = true;
    networkErrorMessage = null;
    notifyListeners();
    try {
      final networkDevices = await _networkScanner.scan();
      if (scanGeneration != _networkScanGeneration) {
        return;
      }
      final nonNetworkDevices = devices
          .where((device) => device.connection != DeviceConnection.network)
          .toList();
      devices = [...nonNetworkDevices, ...networkDevices];
    } catch (error) {
      if (scanGeneration != _networkScanGeneration) {
        return;
      }
      networkErrorMessage = error.toString();
    } finally {
      if (scanGeneration == _networkScanGeneration) {
        isScanningNetwork = false;
        notifyListeners();
      }
    }
  }

  void cancelNetworkScan() {
    if (!isScanningNetwork) return;
    _networkScanGeneration++;
    isScanningNetwork = false;
    notifyListeners();
  }

  void _networkSettingsChanged() {
    _automaticScanTimer?.cancel();
    _localRefreshTimer?.cancel();
    _automaticScanTimer = null;
    if (_networkSettings?.automaticScan == true) {
      _automaticScanTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => refreshNetwork(),
      );
      if (status == DeviceListStatus.loaded) {
        unawaited(refreshNetwork());
      }
    } else {
      cancelNetworkScan();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _automaticScanTimer?.cancel();
    _networkSettings?.removeListener(_networkSettingsChanged);
    super.dispose();
  }

  Map<DeviceType, List<Device>> get groupedDevices {
    final groups = <DeviceType, List<Device>>{};
    for (final device in devices) {
      groups.putIfAbsent(device.type, () => []).add(device);
    }
    return groups;
  }
}
