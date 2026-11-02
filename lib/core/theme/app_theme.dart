import 'package:flutter/material.dart';

import 'theme_provider.dart';

abstract final class AppTheme {
  static ThemeData light(AppThemeStyle style) {
    return _theme(style, Brightness.light);
  }

  static ThemeData dark(AppThemeStyle style) {
    return _theme(style, Brightness.dark);
  }

  static ThemeData _theme(AppThemeStyle style, Brightness brightness) {
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
