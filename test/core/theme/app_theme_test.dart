import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devices_and_printers/core/theme/app_theme.dart';
import 'package:devices_and_printers/core/theme/theme_provider.dart';

void main() {
  test('provides themed component styles for every supported theme', () {
    for (final style in AppThemeStyle.values) {
      final light = AppTheme.light(style);
      final dark = AppTheme.dark(style);
      final lightGeometry = light.extension<AppThemeGeometry>()!;
      final darkGeometry = dark.extension<AppThemeGeometry>()!;

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.filledButtonTheme.style, isNotNull);
      expect(light.outlinedButtonTheme.style, isNotNull);
      expect(light.inputDecorationTheme.border, isNotNull);
      expect(lightGeometry.controlRadius, greaterThan(0));
      expect(darkGeometry.controlRadius, lightGeometry.controlRadius);
    }
  });
}
