import 'package:flutter/material.dart';

import 'theme_storage.dart';

enum AppThemeStyle { cupertino, material, fluent }

enum AppInterfaceSize { large, normal, compact }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  final ThemeStorage _storage;
  AppThemeStyle _themeStyle = AppThemeStyle.material;
  ThemeMode _colorMode = ThemeMode.system;
  AppInterfaceSize _interfaceSize = AppInterfaceSize.normal;

  AppThemeStyle get themeStyle => _themeStyle;
  ThemeMode get colorMode => _colorMode;
  AppInterfaceSize get interfaceSize => _interfaceSize;

  Future<void> initialize() async {
    final storedTheme = await _storage.readTheme();
    final storedColorMode = await _storage.readColorMode();
    final storedInterfaceSize = await _storage.readInterfaceSize();
    _themeStyle = _themeFromValue(storedTheme) ?? AppThemeStyle.material;
    _colorMode = _colorModeFromValue(storedColorMode) ?? ThemeMode.system;
    _interfaceSize =
        _interfaceSizeFromValue(storedInterfaceSize) ?? AppInterfaceSize.normal;
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

  Future<void> setInterfaceSize(AppInterfaceSize interfaceSize) async {
    if (_interfaceSize == interfaceSize) {
      return;
    }
    _interfaceSize = interfaceSize;
    await _storage.writeInterfaceSize(interfaceSize.name);
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

  AppInterfaceSize? _interfaceSizeFromValue(String? value) {
    for (final size in AppInterfaceSize.values) {
      if (size.name == value) {
        return size;
      }
    }
    return null;
  }
}
