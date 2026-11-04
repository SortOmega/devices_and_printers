// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Devices and Printers';

  @override
  String get viewDevices => 'View Devices';

  @override
  String get about => 'About';

  @override
  String get sortName => 'Sort: Name';

  @override
  String get sortStatus => 'Sort: Status';

  @override
  String get sortConnection => 'Sort: Connection';

  @override
  String get groupType => 'Group: Type';

  @override
  String get groupStatus => 'Group: Status';

  @override
  String get groupConnection => 'Group: Connection';

  @override
  String get groupDefault => 'Default';

  @override
  String get windowsDevices => 'Devices';

  @override
  String get windowsPrinters => 'Printers and plotters';

  @override
  String get windowsUnknown => 'Unknown devices';

  @override
  String get addDevice => 'Add Device';

  @override
  String get addPrinter => 'Add Printer';

  @override
  String get refreshDevices => 'Refresh devices';

  @override
  String get close => 'Close';

  @override
  String get tryAgain => 'Try again';

  @override
  String get unableToLoadDevices => 'Unable to load devices';

  @override
  String unableToQuerySystemDevices(Object error) {
    return 'Unable to query system devices: $error';
  }

  @override
  String get noConnectedDevices =>
      'No connected devices or printers were found.';

  @override
  String knownDevices(int count) {
    return '$count known devices';
  }

  @override
  String addItemUnavailable(Object item) {
    return '$item will be available when system configuration integration is added.';
  }

  @override
  String get aboutDescription =>
      'A centralized Linux view for discovering and managing connected devices and printers.';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeCupertino => 'Cupertino';

  @override
  String get themeMaterial => 'Material';

  @override
  String get themeFluent => 'Fluent';

  @override
  String get colorMode => 'Color mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System default';

  @override
  String get interfaceSize => 'Interface size';

  @override
  String get interfaceSizeLarge => 'Large';

  @override
  String get interfaceSizeNormal => 'Normal';

  @override
  String get interfaceSizeCompact => 'Compact';

  @override
  String get systemLanguage => 'System language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get printers => 'Printers';

  @override
  String get plotters => 'Plotters';

  @override
  String get monitors => 'Monitors';

  @override
  String get headsets => 'Headsets';

  @override
  String get microphones => 'Microphones';

  @override
  String get mice => 'Mice';

  @override
  String get keyboards => 'Keyboards';

  @override
  String get phones => 'Phones';

  @override
  String get cameras => 'Cameras';

  @override
  String get storage => 'Storage';

  @override
  String get unknownDevices => 'Unknown devices';

  @override
  String get bluetoothDevices => 'Bluetooth devices';

  @override
  String get usb => 'USB';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get audioJack => 'Audio jack';

  @override
  String get network => 'Network';

  @override
  String get local => 'Local';

  @override
  String get unknownConnection => 'Unknown connection';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get disconnected => 'Disconnected';
}
