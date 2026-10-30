import 'package:flutter/foundation.dart';

import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';

enum DeviceListStatus { initial, loading, loaded, error }

class DeviceListViewModel extends ChangeNotifier {
  DeviceListViewModel(this._repository);

  final DeviceRepository _repository;
  DeviceListStatus status = DeviceListStatus.initial;
  List<Device> devices = const [];
  String? errorMessage;

  Future<void> loadDevices() async {
    status = DeviceListStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      devices = await _repository.getDevices();
      status = DeviceListStatus.loaded;
    } catch (error) {
      status = DeviceListStatus.error;
      errorMessage = 'Unable to query system devices: $error';
    }
    notifyListeners();
  }

  Map<DeviceType, List<Device>> get groupedDevices {
    final groups = <DeviceType, List<Device>>{};
    for (final device in devices) {
      groups.putIfAbsent(device.type, () => []).add(device);
    }
    return groups;
  }
}
