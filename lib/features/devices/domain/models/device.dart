enum DeviceType {
  printer,
  plotter,
  monitor,
  headset,
  microphone,
  mouse,
  keyboard,
  phone,
  camera,
  storage,
  unknown,
  bluetooth,
  router,
  networkDevice,
}

enum DeviceConnection { usb, bluetooth, audioJack, network, local, unknown }

enum DeviceStatus { active, inactive, disconnected }

class DeviceComponent {
  const DeviceComponent({
    required this.id,
    required this.name,
    required this.type,
    required this.connection,
    required this.status,
    this.details,
    this.vendor,
    this.connectionPort,
    this.additionalDetails = const {},
  });

  final String id;
  final String name;
  final DeviceType type;
  final DeviceConnection connection;
  final DeviceStatus status;
  final String? details;
  final String? vendor;
  final String? connectionPort;
  final Map<String, String> additionalDetails;
}

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.connection,
    required this.status,
    this.details,
    this.vendor,
    this.connectionPort,
    this.additionalDetails = const {},
    this.components = const [],
  });

  final String id;
  final String name;
  final DeviceType type;
  final DeviceConnection connection;
  final DeviceStatus status;
  final String? details;
  final String? vendor;
  final String? connectionPort;
  final Map<String, String> additionalDetails;
  final List<DeviceComponent> components;

  bool get isPrinter => type == DeviceType.printer;

  bool get isActive => status == DeviceStatus.active;

  Device copyWith({List<DeviceComponent>? components}) {
    return Device(
      id: id,
      name: name,
      type: type,
      connection: connection,
      status: status,
      details: details,
      vendor: vendor,
      connectionPort: connectionPort,
      additionalDetails: additionalDetails,
      components: components ?? this.components,
    );
  }

  DeviceComponent toComponent() {
    return DeviceComponent(
      id: id,
      name: name,
      type: type,
      connection: connection,
      status: status,
      details: details,
      vendor: vendor,
      connectionPort: connectionPort,
      additionalDetails: additionalDetails,
    );
  }
}
