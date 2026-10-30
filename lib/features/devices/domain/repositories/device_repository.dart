import '../models/device.dart';

abstract interface class DeviceRepository {
  Future<List<Device>> getDevices();
}
