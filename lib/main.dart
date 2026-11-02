import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/locale_provider.dart';
import 'core/localization/locale_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/devices/data/repositories/system_device_repository.dart';
import 'features/devices/presentation/view_models/device_list_view_model.dart';
import 'features/devices/presentation/widgets/device_list_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final localeProvider = LocaleProvider(
    SharedPreferencesLocaleStorage(preferences),
  );
  await localeProvider.initialize();
  runApp(MyApp(localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.localeProvider, super.key});

  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    final viewModel = DeviceListViewModel(SystemDeviceRepository())
      ..loadDevices();

    return AnimatedBuilder(
      animation: localeProvider,
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
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: DeviceListScreen(
          viewModel: viewModel,
          localeProvider: localeProvider,
        ),
      ),
    );
  }
}
