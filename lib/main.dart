import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/devices/data/repositories/system_device_repository.dart';
import 'features/devices/presentation/view_models/device_list_view_model.dart';
import 'features/devices/presentation/widgets/device_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DeviceListViewModel(SystemDeviceRepository())
      ..loadDevices();

    return MaterialApp(
      title: 'Devices and Printers',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: DeviceListScreen(viewModel: viewModel),
    );
  }
}
