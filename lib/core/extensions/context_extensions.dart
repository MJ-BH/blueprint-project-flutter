import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get mediaQuerySize => MediaQuery.of(this).size;
  double get screenWidth => mediaQuerySize.width;
  double get screenHeight => mediaQuerySize.height;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
