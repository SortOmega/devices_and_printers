import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/data_sources/network_device_scanner.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';

enum DeviceListStatus { initial, loading, loaded, error }

class DeviceListViewModel extends ChangeNotifier {
  DeviceListViewModel(this._repository, [this._networkScanner]);

  final DeviceRepository _repository;
  final NetworkDeviceScanner? _networkScanner;
  DeviceListStatus status = DeviceListStatus.initial;
  List<Device> devices = const [];
  String? errorMessage;
  String? networkErrorMessage;
  bool isScanningNetwork = false;
  int _loadGeneration = 0;

  Future<void> loadDevices() async {
    final loadGeneration = ++_loadGeneration;
    status = DeviceListStatus.loading;
    errorMessage = null;
    networkErrorMessage = null;
    isScanningNetwork = false;
    notifyListeners();
    try {
      devices = await _repository.getDevices();
      status = DeviceListStatus.loaded;
    } catch (error) {
      status = DeviceListStatus.error;
      errorMessage = error.toString();
    }
    notifyListeners();
    if (status == DeviceListStatus.loaded && _networkScanner != null) {
      unawaited(_scanNetwork(loadGeneration));
    }
  }

  Future<void> _scanNetwork(int loadGeneration) async {
    isScanningNetwork = true;
    notifyListeners();
    try {
      final networkDevices = await _networkScanner!.scan();
      if (loadGeneration != _loadGeneration) {
        return;
      }
      final knownIds = devices.map((device) => device.id).toSet();
      devices = [
        ...devices,
        ...networkDevices.where((device) => knownIds.add(device.id)),
      ];
    } catch (error) {
      if (loadGeneration != _loadGeneration) {
        return;
      }
      networkErrorMessage = error.toString();
    } finally {
      if (loadGeneration == _loadGeneration) {
        isScanningNetwork = false;
        notifyListeners();
      }
    }
  }

  Map<DeviceType, List<Device>> get groupedDevices {
    final groups = <DeviceType, List<Device>>{};
    for (final device in devices) {
      groups.putIfAbsent(device.type, () => []).add(device);
    }
    return groups;
  }
}
