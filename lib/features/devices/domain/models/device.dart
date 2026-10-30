enum DeviceType {
  printer,
  monitor,
  headset,
  mouse,
  keyboard,
  phone,
  camera,
  storage,
  bluetooth,
}

enum DeviceConnection { usb, bluetooth, network, local, unknown }

enum DeviceStatus { active, inactive, disconnected }

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.connection,
    required this.status,
    this.details,
  });

  final String id;
  final String name;
  final DeviceType type;
  final DeviceConnection connection;
  final DeviceStatus status;
  final String? details;

  bool get isPrinter => type == DeviceType.printer;

  bool get isActive => status == DeviceStatus.active;
}
