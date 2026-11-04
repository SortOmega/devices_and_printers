import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/core/theme/theme_provider.dart';
import 'package:devices_and_printers/core/theme/theme_storage.dart';

class FakeThemeStorage implements ThemeStorage {
  FakeThemeStorage([this.value]);

  String? value;
  String? colorMode;
  String? interfaceSize;

  @override
  Future<String?> readTheme() async => value;

  @override
  Future<void> writeTheme(String theme) async => value = theme;

  @override
  Future<String?> readColorMode() async => colorMode;

  @override
  Future<void> writeColorMode(String value) async => colorMode = value;

  @override
  Future<String?> readInterfaceSize() async => interfaceSize;

  @override
  Future<void> writeInterfaceSize(String value) async => interfaceSize = value;
}

void main() {
  test('uses Material when persisted theme is missing or invalid', () async {
    final missing = ThemeProvider(FakeThemeStorage());
    await missing.initialize();
    expect(missing.themeStyle, AppThemeStyle.material);

    final invalid = ThemeProvider(FakeThemeStorage('unknown'));
    await invalid.initialize();
    expect(invalid.themeStyle, AppThemeStyle.material);
  });

  test('loads and persists the selected theme style', () async {
    final storage = FakeThemeStorage('cupertino');
    final provider = ThemeProvider(storage);
    await provider.initialize();

    expect(provider.themeStyle, AppThemeStyle.cupertino);

    await provider.setThemeStyle(AppThemeStyle.fluent);

    expect(provider.themeStyle, AppThemeStyle.fluent);
    expect(storage.value, 'fluent');
  });

  test('uses System Default when color mode is missing or invalid', () async {
    final missing = ThemeProvider(FakeThemeStorage());
    await missing.initialize();
    expect(missing.colorMode, ThemeMode.system);

    final invalidStorage = FakeThemeStorage()..colorMode = 'invalid';
    final invalid = ThemeProvider(invalidStorage);
    await invalid.initialize();
    expect(invalid.colorMode, ThemeMode.system);
  });

  test('loads and persists the selected color mode', () async {
    final storage = FakeThemeStorage()..colorMode = 'dark';
    final provider = ThemeProvider(storage);
    await provider.initialize();

    expect(provider.colorMode, ThemeMode.dark);

    await provider.setColorMode(ThemeMode.light);

    expect(provider.colorMode, ThemeMode.light);
    expect(storage.colorMode, 'light');
  });

  test('loads and persists the selected interface size', () async {
    final storage = FakeThemeStorage()..interfaceSize = 'compact';
    final provider = ThemeProvider(storage);
    await provider.initialize();

    expect(provider.interfaceSize, AppInterfaceSize.compact);

    await provider.setInterfaceSize(AppInterfaceSize.large);

    expect(provider.interfaceSize, AppInterfaceSize.large);
    expect(storage.interfaceSize, 'large');
  });
}
