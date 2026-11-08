import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/device.dart';

String labelForType(DeviceType type, AppLocalizations l10n) {
  return switch (type) {
    DeviceType.printer => l10n.printers,
    DeviceType.plotter => l10n.plotters,
    DeviceType.monitor => l10n.monitors,
    DeviceType.headset => l10n.headsets,
    DeviceType.microphone => l10n.microphones,
    DeviceType.mouse => l10n.mice,
    DeviceType.keyboard => l10n.keyboards,
    DeviceType.phone => l10n.phones,
    DeviceType.camera => l10n.cameras,
    DeviceType.storage => l10n.storage,
    DeviceType.unknown => l10n.unknownDevices,
    DeviceType.bluetooth => l10n.bluetoothDevices,
    DeviceType.router => l10n.routers,
    DeviceType.networkDevice => l10n.networkDevices,
  };
}

IconData iconForDevice(Device device) {
  return switch (device.type) {
    DeviceType.printer || DeviceType.plotter => Icons.print,
    DeviceType.monitor => Icons.monitor,
    DeviceType.headset => Icons.headset,
    DeviceType.microphone => Icons.mic,
    DeviceType.mouse => Icons.mouse,
    DeviceType.keyboard => Icons.keyboard,
    DeviceType.phone => Icons.smartphone,
    DeviceType.camera => Icons.camera_alt,
    DeviceType.storage => Icons.storage,
    DeviceType.unknown => Icons.device_unknown,
    DeviceType.bluetooth => Icons.bluetooth,
    DeviceType.router => Icons.router,
    DeviceType.networkDevice => Icons.device_hub,
  };
}

String connectionLabel(DeviceConnection connection, AppLocalizations l10n) {
  return switch (connection) {
    DeviceConnection.usb => l10n.usb,
    DeviceConnection.bluetooth => l10n.bluetooth,
    DeviceConnection.audioJack => l10n.audioJack,
    DeviceConnection.network => l10n.network,
    DeviceConnection.local => l10n.local,
    DeviceConnection.unknown => l10n.unknownConnection,
  };
}

String statusLabel(DeviceStatus status, AppLocalizations l10n) {
  return switch (status) {
    DeviceStatus.active => l10n.active,
    DeviceStatus.inactive => l10n.inactive,
    DeviceStatus.disconnected => l10n.disconnected,
  };
}
