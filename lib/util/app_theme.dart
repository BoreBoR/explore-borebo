import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColor.primaryBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColor.primaryBlue,
          onPrimary: AppColor.surface,
          primaryContainer: AppColor.primaryBlueLight,
          surface: AppColor.surface,
          error: AppColor.error,
          outline: AppColor.outline,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColor.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColor.primaryBlue,
          foregroundColor: AppColor.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
