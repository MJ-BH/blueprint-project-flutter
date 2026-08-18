library app_ui;

export 'src/colors/app_colors.dart';
export 'src/components/app_components.dart';

import 'package:flutter/material.dart';
import 'src/colors/app_colors.dart';

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
