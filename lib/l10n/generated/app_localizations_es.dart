// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Dispositivos e impresoras';

  @override
  String get viewDevices => 'Ver dispositivos';

  @override
  String get about => 'Acerca de';

  @override
  String get sortLabel => 'Ordenar:';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortStatus => 'Estado';

  @override
  String get sortConnection => 'Conexión';

  @override
  String get groupLabel => 'Agrupar:';

  @override
  String get groupType => 'Tipo';

  @override
  String get groupStatus => 'Estado';

  @override
  String get groupConnection => 'Conexión';

  @override
  String get groupDefault => 'Predeterminado';

  @override
  String get windowsDevices => 'Dispositivos';

  @override
  String get windowsPrinters => 'Impresoras y plotters';

  @override
  String get windowsUnknown => 'Dispositivos desconocidos';

  @override
  String get addDevice => 'Añadir dispositivo';

  @override
  String get addPrinter => 'Añadir impresora';

  @override
  String get refreshDevices => 'Actualizar dispositivos';

  @override
  String get close => 'Cerrar';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get unableToLoadDevices => 'No se pudieron cargar los dispositivos';

  @override
  String unableToQuerySystemDevices(Object error) {
    return 'No se pudieron consultar los dispositivos del sistema: $error';
  }

  @override
  String get noConnectedDevices =>
      'No se encontraron dispositivos ni impresoras conectados.';

  @override
  String knownDevices(int count) {
    return '$count dispositivos conocidos';
  }

  @override
  String addItemUnavailable(Object item) {
    return '$item estará disponible cuando se añada la integración con la configuración del sistema.';
  }

  @override
  String get aboutDescription =>
      'Una vista centralizada de Linux para descubrir y gestionar dispositivos e impresoras conectados.';

  @override
  String get language => 'Idioma';

  @override
  String get settings => 'Configuración';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Temática';

  @override
  String get themeCupertino => 'Cupertino';

  @override
  String get themeMaterial => 'Material';

  @override
  String get themeFluent => 'Fluent';

  @override
  String get colorMode => 'Modo de color';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get interfaceSize => 'Tamaño de interfaz';

  @override
  String get interfaceSizeLarge => 'Grande';

  @override
  String get interfaceSizeNormal => 'Normal';

  @override
  String get interfaceSizeCompact => 'Compacto';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get printers => 'Impresoras';

  @override
  String get plotters => 'Plotters';

  @override
  String get monitors => 'Monitores';

  @override
  String get headsets => 'Auriculares';

  @override
  String get microphones => 'Micrófonos';

  @override
  String get mice => 'Ratones';

  @override
  String get keyboards => 'Teclados';

  @override
  String get phones => 'Teléfonos';

  @override
  String get cameras => 'Cámaras';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get unknownDevices => 'Dispositivos desconocidos';

  @override
  String get bluetoothDevices => 'Dispositivos Bluetooth';

  @override
  String get usb => 'USB';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get audioJack => 'Conector de audio';

  @override
  String get network => 'Red';

  @override
  String get local => 'Local';

  @override
  String get unknownConnection => 'Conexión desconocida';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get deviceInfoTab => 'Info';

  @override
  String get deviceConfigTab => 'Confg';

  @override
  String get workInProgress => 'En desarrollo';

  @override
  String get deviceId => 'ID del dispositivo';

  @override
  String get deviceType => 'Tipo de dispositivo';

  @override
  String get deviceStatus => 'Estado';

  @override
  String get deviceConnection => 'Conexión';

  @override
  String get devicePort => 'Puerto';

  @override
  String get deviceDetails => 'Detalles';

  @override
  String get deviceVendor => 'Proveedor';

  @override
  String get deviceComponents => 'Componentes';

  @override
  String get routers => 'Routers y puntos de acceso';

  @override
  String get networkDevices => 'Dispositivos de red';
}
