import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemeStorage {
  Future<String?> readTheme();

  Future<void> writeTheme(String theme);
}

class SharedPreferencesThemeStorage implements ThemeStorage {
  SharedPreferencesThemeStorage(this._preferences);

  final SharedPreferences _preferences;
  static const _themeKey = 'theme';

  @override
  Future<String?> readTheme() async => _preferences.getString(_themeKey);

  @override
  Future<void> writeTheme(String theme) async {
    await _preferences.setString(_themeKey, theme);
  }
}
