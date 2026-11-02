import 'package:flutter/material.dart';

import 'theme_storage.dart';

enum AppThemeStyle { cupertino, material, fluent }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  final ThemeStorage _storage;
  AppThemeStyle _themeStyle = AppThemeStyle.material;
  ThemeMode _colorMode = ThemeMode.system;

  AppThemeStyle get themeStyle => _themeStyle;
  ThemeMode get colorMode => _colorMode;

  Future<void> initialize() async {
    final storedTheme = await _storage.readTheme();
    final storedColorMode = await _storage.readColorMode();
    _themeStyle = _themeFromValue(storedTheme) ?? AppThemeStyle.material;
    _colorMode = _colorModeFromValue(storedColorMode) ?? ThemeMode.system;
  }

  Future<void> setThemeStyle(AppThemeStyle themeStyle) async {
    if (_themeStyle == themeStyle) {
      return;
    }
    _themeStyle = themeStyle;
    await _storage.writeTheme(themeStyle.name);
    notifyListeners();
  }

  Future<void> setColorMode(ThemeMode colorMode) async {
    if (_colorMode == colorMode) {
      return;
    }
    _colorMode = colorMode;
    await _storage.writeColorMode(colorMode.name);
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

  ThemeMode? _colorModeFromValue(String? value) {
    for (final mode in ThemeMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }
    return null;
  }
}
