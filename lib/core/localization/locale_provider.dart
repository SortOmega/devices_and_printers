import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'locale_storage.dart';

class LocaleProvider extends ChangeNotifier with WidgetsBindingObserver {
  LocaleProvider(this._storage);

  final LocaleStorage _storage;
  Locale? _locale;
  bool _isInitialized = false;
  bool _hasManualLocale = false;

  Locale? get locale => _locale;
  bool get isInitialized => _isInitialized;
  bool get hasManualLocale => _hasManualLocale;

  static const supportedLocales = [Locale('en'), Locale('es')];

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    final storedLocale = await _storage.readLocale();
    _hasManualLocale = storedLocale == 'en' || storedLocale == 'es';
    _locale = _hasManualLocale
        ? Locale(storedLocale!)
        : _localeFor(ui.PlatformDispatcher.instance.locale);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) {
      return;
    }
    _hasManualLocale = true;
    _locale = Locale(locale.languageCode);
    await _storage.writeLocale(locale.languageCode);
    notifyListeners();
  }

  Future<void> useSystemLocale() async {
    _hasManualLocale = false;
    _locale = _localeFor(ui.PlatformDispatcher.instance.locale);
    await _storage.clearLocale();
    notifyListeners();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (!_hasManualLocale && locales != null && locales.isNotEmpty) {
      final resolvedLocale = _localeFor(locales.first);
      if (_locale != resolvedLocale) {
        _locale = resolvedLocale;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Locale _localeFor(Locale locale) {
    return _isSupported(locale)
        ? Locale(locale.languageCode)
        : const Locale('en');
  }

  bool _isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}
