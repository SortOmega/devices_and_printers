import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData.light(useMaterial3: true);

  static ThemeData get dark => ThemeData.dark(useMaterial3: true);
}
