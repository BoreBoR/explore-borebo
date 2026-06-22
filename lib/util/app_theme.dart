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
          secondary: AppColor.blushDeep,
          secondaryContainer: AppColor.blush,
          tertiary: AppColor.warmGold,
          tertiaryContainer: Color(0xFFFFF1D5),
          surface: AppColor.surface,
          surfaceContainerHighest: AppColor.surfaceMuted,
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
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          elevation: 3,
          shadowColor: AppColor.primaryBlueDark.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColor.primaryBlue,
          backgroundColor: AppColor.surface.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
