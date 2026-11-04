import 'package:flutter/material.dart';

import 'theme_provider.dart';

abstract final class AppTheme {
  static ThemeData light(
    AppThemeStyle style, [
    AppInterfaceSize interfaceSize = AppInterfaceSize.normal,
  ]) {
    return _theme(style, Brightness.light, interfaceSize);
  }

  static ThemeData dark(
    AppThemeStyle style, [
    AppInterfaceSize interfaceSize = AppInterfaceSize.normal,
  ]) {
    return _theme(style, Brightness.dark, interfaceSize);
  }

  static ThemeData _theme(
    AppThemeStyle style,
    Brightness brightness,
    AppInterfaceSize interfaceSize,
  ) {
    final geometry = _geometry(style);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: switch (style) {
        AppThemeStyle.cupertino => const Color(0xff007aff),
        AppThemeStyle.material => const Color(0xff6750a4),
        AppThemeStyle.fluent => const Color(0xff0067c0),
      },
      brightness: brightness,
    );
    final base = ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      useMaterial3: true,
      visualDensity: _visualDensity(interfaceSize),
      textTheme: _textTheme(interfaceSize, brightness),
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [geometry],
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: style == AppThemeStyle.material ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(geometry.cardRadius)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: style == AppThemeStyle.material ? 1 : 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(geometry.controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(geometry.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(geometry.controlRadius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(geometry.controlRadius),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(geometry.controlRadius),
            ),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: brightness == Brightness.dark ? 0.35 : 0.55,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(geometry.controlRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? 0.35 : 0.55,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(geometry.controlRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(geometry.controlRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(geometry.controlRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(geometry.dialogRadius),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(geometry.controlRadius),
        ),
        textStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );

    return switch (style) {
      AppThemeStyle.material => base,
      AppThemeStyle.cupertino => base,
      AppThemeStyle.fluent => base,
    };
  }

  static VisualDensity _visualDensity(AppInterfaceSize size) {
    return switch (size) {
      AppInterfaceSize.large => VisualDensity.comfortable,
      AppInterfaceSize.normal => VisualDensity.standard,
      AppInterfaceSize.compact => VisualDensity.compact,
    };
  }

  static TextTheme _textTheme(AppInterfaceSize size, Brightness brightness) {
    final double factor = switch (size) {
      AppInterfaceSize.large => 1.15,
      AppInterfaceSize.normal => 1.0,
      AppInterfaceSize.compact => 0.9,
    };
    final textTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    ).textTheme;
    TextStyle scale(TextStyle? style, double defaultSize) {
      return (style ?? const TextStyle()).copyWith(
        fontSize: (style?.fontSize ?? defaultSize) * factor,
      );
    }

    return textTheme.copyWith(
      displayLarge: scale(textTheme.displayLarge, 57),
      displayMedium: scale(textTheme.displayMedium, 45),
      displaySmall: scale(textTheme.displaySmall, 36),
      headlineLarge: scale(textTheme.headlineLarge, 32),
      headlineMedium: scale(textTheme.headlineMedium, 28),
      headlineSmall: scale(textTheme.headlineSmall, 24),
      titleLarge: scale(textTheme.titleLarge, 22),
      titleMedium: scale(textTheme.titleMedium, 16),
      titleSmall: scale(textTheme.titleSmall, 14),
      bodyLarge: scale(textTheme.bodyLarge, 16),
      bodyMedium: scale(textTheme.bodyMedium, 14),
      bodySmall: scale(textTheme.bodySmall, 12),
      labelLarge: scale(textTheme.labelLarge, 14),
      labelMedium: scale(textTheme.labelMedium, 12),
      labelSmall: scale(textTheme.labelSmall, 11),
    );
  }

  static AppThemeGeometry _geometry(AppThemeStyle style) {
    return switch (style) {
      AppThemeStyle.cupertino => const AppThemeGeometry(
        cardRadius: 12,
        controlRadius: 10,
        dialogRadius: 14,
      ),
      AppThemeStyle.material => const AppThemeGeometry(
        cardRadius: 12,
        controlRadius: 20,
        dialogRadius: 28,
      ),
      AppThemeStyle.fluent => const AppThemeGeometry(
        cardRadius: 4,
        controlRadius: 4,
        dialogRadius: 4,
      ),
    };
  }
}

@immutable
class AppThemeGeometry extends ThemeExtension<AppThemeGeometry> {
  const AppThemeGeometry({
    required this.cardRadius,
    required this.controlRadius,
    required this.dialogRadius,
  });

  final double cardRadius;
  final double controlRadius;
  final double dialogRadius;

  @override
  AppThemeGeometry copyWith({
    double? cardRadius,
    double? controlRadius,
    double? dialogRadius,
  }) {
    return AppThemeGeometry(
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      dialogRadius: dialogRadius ?? this.dialogRadius,
    );
  }

  @override
  AppThemeGeometry lerp(
    covariant ThemeExtension<AppThemeGeometry>? other,
    double t,
  ) {
    if (other is! AppThemeGeometry) {
      return this;
    }
    return AppThemeGeometry(
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
      controlRadius: lerpDouble(controlRadius, other.controlRadius, t),
      dialogRadius: lerpDouble(dialogRadius, other.dialogRadius, t),
    );
  }

  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
