import 'package:flutter/foundation.dart';

import 'theme_storage.dart';

enum AppThemeStyle { cupertino, material, fluent }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  final ThemeStorage _storage;
  AppThemeStyle _themeStyle = AppThemeStyle.material;

  AppThemeStyle get themeStyle => _themeStyle;

  Future<void> initialize() async {
    final storedTheme = await _storage.readTheme();
    _themeStyle = _themeFromValue(storedTheme) ?? AppThemeStyle.material;
  }

  Future<void> setThemeStyle(AppThemeStyle themeStyle) async {
    if (_themeStyle == themeStyle) {
      return;
    }
    _themeStyle = themeStyle;
    await _storage.writeTheme(themeStyle.name);
    notifyListeners();
  }

  AppThemeStyle? _themeFromValue(String? value) {
    for (final theme in AppThemeStyle.values) {
      if (theme.name == value) {
        return theme;
      }
    }
    return null;
  }
}
