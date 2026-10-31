import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/features/devices/domain/models/device.dart';
import 'package:devices_and_printers/features/devices/domain/repositories/device_repository.dart';
import 'package:devices_and_printers/features/devices/presentation/view_models/device_list_view_model.dart';
import 'package:devices_and_printers/features/devices/presentation/widgets/device_list_screen.dart';

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

void main() {
  testWidgets('shows queried devices grouped by type', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      MaterialApp(home: DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monitors'), findsOneWidget);
    expect(find.text('Office Monitor'), findsOneWidget);
    expect(find.byIcon(Icons.monitor), findsOneWidget);
    expect(find.text('Active · USB'), findsOneWidget);
  });

  testWidgets('shows a border only after selecting a device', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      MaterialApp(home: DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('monitor:monitor'));
    AnimatedContainer container = tester.widget(card);
    final initialDecoration = container.decoration! as BoxDecoration;
    expect(initialDecoration.border!.top.color, Colors.transparent);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office Monitor'));
    await tester.pumpAndSettle();

    container = tester.widget(card);
    final selectedDecoration = container.decoration! as BoxDecoration;
    expect(selectedDecoration.border!.top.color, isNot(Colors.transparent));
  });

  testWidgets('keeps only one card selected at a time', (
    WidgetTester tester,
  ) async {
    final viewModel = DeviceListViewModel(FakeDeviceRepository())
      ..loadDevices();

    await tester.pumpWidget(
      MaterialApp(home: DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office Monitor'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
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
      MaterialApp(home: DeviceListScreen(viewModel: viewModel)),
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
      MaterialApp(home: DeviceListScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sort: Name'), findsOneWidget);
    expect(find.text('Group: Type'), findsOneWidget);

    await tester.tap(find.text('Sort: Name'));
    await tester.pumpAndSettle();
    expect(find.text('Sort: Status'), findsOneWidget);
    await tester.tap(find.text('Sort: Status'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Group: Type'));
    await tester.pumpAndSettle();
    expect(find.text('Group: Status'), findsOneWidget);
  });
}
