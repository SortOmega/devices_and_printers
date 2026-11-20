import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/locale_provider.dart';
import 'core/localization/locale_storage.dart';
import 'core/network/network_scan_settings.dart';
import 'core/network/shared_preferences_network_scan_settings_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/theme_storage.dart';
import 'features/devices/data/repositories/system_device_repository.dart';
import 'features/devices/data/data_sources/network_device_scanner.dart';
import 'features/devices/data/data_sources/device_cache.dart';
import 'features/devices/domain/models/device.dart';
import 'features/devices/domain/repositories/device_repository.dart';
import 'features/devices/presentation/view_models/device_list_view_model.dart';
import 'features/devices/presentation/widgets/windows/devices_window.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final localeProvider = LocaleProvider(
    SharedPreferencesLocaleStorage(preferences),
  );
  final themeProvider = ThemeProvider(
    SharedPreferencesThemeStorage(preferences),
  );
  final networkSettings = NetworkScanSettings(
    SharedPreferencesNetworkScanSettingsStorage(preferences),
  );
  await localeProvider.initialize();
  await themeProvider.initialize();
  await networkSettings.initialize();
  final deviceCache = DeviceCache(preferences);
  final repository = SystemDeviceRepository(cache: deviceCache);
  runApp(
    MyApp(
      localeProvider: localeProvider,
      themeProvider: themeProvider,
      networkSettings: networkSettings,
      repository: repository,
      initialDevices: deviceCache.load(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.localeProvider,
    required this.themeProvider,
    required this.networkSettings,
    required this.repository,
    required this.initialDevices,
    super.key,
  });

  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  final NetworkScanSettings networkSettings;
  final DeviceRepository repository;
  final List<Device> initialDevices;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DeviceListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DeviceListViewModel(
      widget.repository,
      SocketNetworkDeviceScanner(),
      widget.networkSettings,
      const Duration(seconds: 1),
      widget.initialDevices,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_viewModel.loadDevices());
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.localeProvider,
        widget.themeProvider,
      ]),
      builder: (context, _) => MaterialApp(
        locale: widget.localeProvider.locale,
        supportedLocales: LocaleProvider.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.light(
          widget.themeProvider.themeStyle,
          widget.themeProvider.interfaceSize,
        ),
        darkTheme: AppTheme.dark(
          widget.themeProvider.themeStyle,
          widget.themeProvider.interfaceSize,
        ),
        themeMode: widget.themeProvider.colorMode,
        home: DeviceListScreen(
          viewModel: _viewModel,
          localeProvider: widget.localeProvider,
          themeProvider: widget.themeProvider,
          networkSettings: widget.networkSettings,
        ),
      ),
    );
  }
}
