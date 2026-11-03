import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/locale_provider.dart';
import 'core/localization/locale_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/theme_storage.dart';
import 'features/devices/data/repositories/system_device_repository.dart';
import 'features/devices/data/data_sources/network_device_scanner.dart';
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
  await localeProvider.initialize();
  await themeProvider.initialize();
  runApp(MyApp(localeProvider: localeProvider, themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.localeProvider,
    required this.themeProvider,
    super.key,
  });

  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    final viewModel = DeviceListViewModel(
      SystemDeviceRepository(),
      SocketNetworkDeviceScanner(),
    )..loadDevices();

    return AnimatedBuilder(
      animation: Listenable.merge([localeProvider, themeProvider]),
      builder: (context, _) => MaterialApp(
        locale: localeProvider.locale,
        supportedLocales: LocaleProvider.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.light(themeProvider.themeStyle),
        darkTheme: AppTheme.dark(themeProvider.themeStyle),
        themeMode: themeProvider.colorMode,
        home: DeviceListScreen(
          viewModel: viewModel,
          localeProvider: localeProvider,
          themeProvider: themeProvider,
        ),
      ),
    );
  }
}
