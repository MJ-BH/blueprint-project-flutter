library app_ui;

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F172A);
  static const Color accent = Color(0xFF38BDF8);
  static const Color background = Color(0xFF090D16);
  static const Color cardBg = Color(0xFF1E293B);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.cardBg,
      ),
      useMaterial3: true,
    );
  }
}
