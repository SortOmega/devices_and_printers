import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocaleStorage {
  Future<String?> readLocale();

  Future<void> writeLocale(String locale);

  Future<void> clearLocale();
}

class SharedPreferencesLocaleStorage implements LocaleStorage {
  SharedPreferencesLocaleStorage(this._preferences);

  final SharedPreferences _preferences;
  static const _localeKey = 'locale';

  @override
  Future<String?> readLocale() async => _preferences.getString(_localeKey);

  @override
  Future<void> writeLocale(String locale) async {
    await _preferences.setString(_localeKey, locale);
  }

  @override
  Future<void> clearLocale() async {
    await _preferences.remove(_localeKey);
  }
}
