import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/core/localization/locale_provider.dart';
import 'package:devices_and_printers/core/localization/locale_storage.dart';

class FakeLocaleStorage implements LocaleStorage {
  FakeLocaleStorage([this.value]);

  String? value;

  @override
  Future<void> clearLocale() async => value = null;

  @override
  Future<String?> readLocale() async => value;

  @override
  Future<void> writeLocale(String locale) async => value = locale;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('uses English when persisted locale is unsupported', () async {
    final provider = LocaleProvider(FakeLocaleStorage('fr'));

    await provider.initialize();

    expect(provider.locale, const Locale('en'));
    expect(provider.hasManualLocale, isFalse);
    provider.dispose();
  });

  test(
    'persists manual language changes and can return to system language',
    () async {
      final storage = FakeLocaleStorage();
      final provider = LocaleProvider(storage);
      await provider.initialize();

      await provider.setLocale(const Locale('es'));
      expect(provider.locale, const Locale('es'));
      expect(storage.value, 'es');
      expect(provider.hasManualLocale, isTrue);

      await provider.useSystemLocale();
      expect(storage.value, isNull);
      expect(provider.hasManualLocale, isFalse);
      expect(provider.locale, const Locale('en'));
      provider.dispose();
    },
  );

  test('reacts to system locale changes without a manual override', () async {
    final provider = LocaleProvider(FakeLocaleStorage());
    await provider.initialize();

    provider.didChangeLocales(const [Locale('es')]);

    expect(provider.locale, const Locale('es'));
    provider.dispose();
  });

  test(
    'ignores system locale changes while a manual override is active',
    () async {
      final provider = LocaleProvider(FakeLocaleStorage());
      await provider.initialize();
      await provider.setLocale(const Locale('en'));

      provider.didChangeLocales(const [Locale('es')]);

      expect(provider.locale, const Locale('en'));
      provider.dispose();
    },
  );
}
