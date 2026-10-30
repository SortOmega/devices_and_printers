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
      id: 'printer:office',
      name: 'Office printer',
      type: DeviceType.printer,
      connection: DeviceConnection.network,
      status: DeviceStatus.recognized,
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

    expect(find.text('Printers'), findsOneWidget);
    expect(find.text('Office printer'), findsOneWidget);
  });
}
