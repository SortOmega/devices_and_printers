import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemeStorage {
  Future<String?> readTheme();

  Future<void> writeTheme(String theme);

  Future<String?> readColorMode();

  Future<void> writeColorMode(String colorMode);

  Future<String?> readInterfaceSize();

  Future<void> writeInterfaceSize(String interfaceSize);
}

class SharedPreferencesThemeStorage implements ThemeStorage {
  SharedPreferencesThemeStorage(this._preferences);

  final SharedPreferences _preferences;
  static const _themeKey = 'theme';
  static const _colorModeKey = 'colorMode';
  static const _interfaceSizeKey = 'interfaceSize';

  @override
  Future<String?> readTheme() async => _preferences.getString(_themeKey);

  @override
  Future<void> writeTheme(String theme) async {
    await _preferences.setString(_themeKey, theme);
  }

  @override
  Future<String?> readColorMode() async =>
      _preferences.getString(_colorModeKey);

  @override
  Future<void> writeColorMode(String colorMode) async {
    await _preferences.setString(_colorModeKey, colorMode);
  }

  @override
  Future<String?> readInterfaceSize() async =>
      _preferences.getString(_interfaceSizeKey);

  @override
  Future<void> writeInterfaceSize(String interfaceSize) async {
    await _preferences.setString(_interfaceSizeKey, interfaceSize);
  }
}
