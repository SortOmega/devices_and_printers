import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/features/devices/domain/models/device.dart';
import 'package:devices_and_printers/features/devices/data/data_sources/network_device_scanner.dart';
import 'package:devices_and_printers/features/devices/domain/repositories/device_repository.dart';
import 'package:devices_and_printers/features/devices/presentation/view_models/device_list_view_model.dart';
import 'package:devices_and_printers/features/devices/presentation/widgets/windows/devices_window.dart';
import 'package:devices_and_printers/l10n/generated/app_localizations.dart';

class FakeDeviceRepository implements DeviceRepository {
  @override
  Future<List<Device>> getDevices() async => [
    const Device(
      id: 'monitor:monitor',
      name: 'Office Monitor',
      type: DeviceType.monitor,
      connection: DeviceConnection.usb,
      status: DeviceStatus.active,
    ),
    const Device(
      id: 'keyboard:keyboard',
      name: 'Office Keyboard',
      type: DeviceType.keyboard,
      connection: DeviceConnection.usb,
      status: DeviceStatus.disconnected,
    ),
  ];
}

class WindowsGroupingRepository implements DeviceRepository {
  @override
  Future<List<Device>> getDevices() async => [
    const Device(
      id: 'monitor:windows',
      name: 'Monitor',
      type: DeviceType.monitor,
      connection: DeviceConnection.usb,
      status: DeviceStatus.active,
    ),
    const Device(
      id: 'printer:windows',
      name: 'Printer',
      type: DeviceType.printer,
      connection: DeviceConnection.network,
      status: DeviceStatus.active,
    ),
    const Device(
      id: 'unknown:windows',
      name: 'Unknown',
      type: DeviceType.unknown,
      connection: DeviceConnection.unknown,
      status: DeviceStatus.inactive,
    ),
  ];
}

Widget localizedApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es')],
    home: home,
  );
}

void main() {
  testWidgets('shows queried devices grouped by type', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Type'));
    await tester.pumpAndSettle();

    expect(find.text('Monitors'), findsOneWidget);
    expect(find.text('Office Monitor'), findsOneWidget);
    expect(find.byIcon(Icons.monitor), findsOneWidget);
    expect(find.text('Active · USB'), findsOneWidget);
  });

  testWidgets('shows network scan progress in the footer', (
    WidgetTester tester,
  ) async {
    final scanner = _PendingNetworkScanner();
    final viewModel = DeviceListViewModel(FakeDeviceRepository(), scanner)
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Searching for devices on the network…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    scanner.complete();
    await tester.pumpAndSettle();
    expect(find.text('Searching for devices on the network…'), findsNothing);
  });

  testWidgets('shows a border only after selecting a device', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('monitor:monitor'));
    AnimatedContainer container = tester.widget(card);
    final initialDecoration = container.decoration! as BoxDecoration;
    expect(initialDecoration.border!.top.color, Colors.transparent);

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office Monitor'));
    await tester.pumpAndSettle();

    container = tester.widget(card);
    final selectedDecoration = container.decoration! as BoxDecoration;
    expect(selectedDecoration.border!.top.color, isNot(Colors.transparent));
  });

  testWidgets('shows device details and a work-in-progress config tab', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(_DetailsRepository())..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detailed Monitor'));
    await tester.pumpAndSettle();

    expect(find.text('Device ID'), findsOneWidget);
    expect(find.text('monitor:detailed'), findsOneWidget);
    expect(find.text('Acme'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('DisplayPort'), findsOneWidget);
    expect(find.text('Components'), findsOneWidget);
    expect(find.text('Display output', skipOffstage: false), findsOneWidget);
    expect(find.text('Monitor speakers', skipOffstage: false), findsOneWidget);
    await tester.tap(find.text('Display output'));
    await tester.pumpAndSettle();
    expect(find.text('monitor:detailed:display'), findsOneWidget);
    expect(find.text('Acme Audio'), findsOneWidget);
    expect(find.text('ALSA playback device'), findsOneWidget);

    await tester.tap(find.text('Config'));
    await tester.pumpAndSettle();
    expect(find.text('Work in progress'), findsOneWidget);
  });

  testWidgets('keeps only one card selected at a time', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office Monitor'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office Keyboard'));
    await tester.pumpAndSettle();

    final cards = <AnimatedContainer>[
      tester.widget(find.byKey(const ValueKey('monitor:monitor'))),
      tester.widget(find.byKey(const ValueKey('keyboard:keyboard'))),
    ];
    final selectedCards = cards.where((card) {
      final decoration = card.decoration! as BoxDecoration;
      return decoration.color != Colors.transparent &&
          decoration.border!.top.color != Colors.transparent;
    });

    expect(selectedCards, hasLength(1));
  });

  testWidgets('switches between the devices and about pages', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('View Devices'), findsOneWidget);
    expect(find.text('Add Device'), findsOneWidget);
    expect(
      find.text(
        'A centralized Linux view for discovering and managing '
        'connected devices and printers.',
      ),
      findsNothing,
    );

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A centralized Linux view for discovering and managing '
        'connected devices and printers.',
      ),
      findsOneWidget,
    );
    expect(find.text('Add Device'), findsNothing);

    await tester.tap(find.text('View Devices'));
    await tester.pumpAndSettle();

    expect(find.text('Add Printer'), findsOneWidget);
  });

  testWidgets('provides device sorting and grouping controls', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sort:'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Group:'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    expect(find.text('Status'), findsOneWidget);
    await tester.tap(find.text('Status'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    expect(find.text('Status'), findsNWidgets(2));
  });

  testWidgets('shows appearance and language settings', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Color mode'), findsOneWidget);
    expect(find.text('Interface size'), findsOneWidget);
    expect(find.text('Language'), findsNWidgets(2));
  });

  testWidgets('supports default device grouping with unknown devices last', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(WindowsGroupingRepository())
      ..loadDevices();

    await tester.pumpWidget(
      localizedApp(DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final devicesFinder = find.text('Devices', skipOffstage: false);
    final printersFinder = find.text(
      'Printers and plotters',
      skipOffstage: false,
    );
    final unknownFinder = find.text('Unknown devices', skipOffstage: false);
    expect(devicesFinder, findsOneWidget);
    expect(printersFinder, findsOneWidget);
    expect(unknownFinder, findsOneWidget);

    final devicesGroup = tester.getTopLeft(devicesFinder).dy;
    final printersGroup = tester.getTopLeft(printersFinder).dy;
    final unknownGroup = tester.getTopLeft(unknownFinder).dy;
    expect(devicesGroup, lessThan(printersGroup));
    expect(printersGroup, lessThan(unknownGroup));
  });
}

class _DetailsRepository implements DeviceRepository {
  @override
  Future<List<Device>> getDevices() async => [
    const Device(
      id: 'monitor:detailed',
      name: 'Detailed Monitor',
      vendor: 'Acme',
      type: DeviceType.monitor,
      connection: DeviceConnection.usb,
      connectionPort: 'DisplayPort',
      status: DeviceStatus.active,
      components: [
        DeviceComponent(
          id: 'monitor:detailed:display',
          name: 'Display output',
          type: DeviceType.monitor,
          connection: DeviceConnection.usb,
          status: DeviceStatus.active,
          details: 'ALSA playback device',
          vendor: 'Acme Audio',
          connectionPort: 'DisplayPort',
        ),
        DeviceComponent(
          id: 'monitor:detailed:audio',
          name: 'Monitor speakers',
          type: DeviceType.headset,
          connection: DeviceConnection.audioJack,
          status: DeviceStatus.active,
          details: 'ALSA capture device',
          connectionPort: 'HDMI',
        ),
      ],
    ),
  ];
}

class _PendingNetworkScanner implements NetworkDeviceScanner {
  final Completer<List<Device>> _completer = Completer<List<Device>>();

  void complete() => _completer.complete(const []);

  @override
  Future<List<Device>> scan() => _completer.future;
}
