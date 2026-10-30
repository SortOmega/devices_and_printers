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

    final card = find.byType(AnimatedContainer).first;
    AnimatedContainer container = tester.widget(card);
    final initialDecoration = container.decoration! as BoxDecoration;
    expect(initialDecoration.border!.top.color, Colors.transparent);

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

    await tester.tap(find.text('Office Monitor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office Keyboard'));
    await tester.pumpAndSettle();

    final cards = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final selectedCards = cards.where((card) {
      final decoration = card.decoration! as BoxDecoration;
      return decoration.color != Colors.transparent &&
          decoration.border!.top.color != Colors.transparent;
    });

    expect(selectedCards, hasLength(1));
  });
}
