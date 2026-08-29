import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light and dark themes.
///
/// Deliberately minimal: only [ColorScheme] and canvas colours are set on
/// [ThemeData]. Component styling lives in the reusable widgets under
/// `lib/ui/widgets/`, which keeps the app rendering identically across
/// Flutter versions.
class AppTheme {
  const AppTheme._();

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primarySoft,
      onSecondary: Colors.white,
      surface: AppColors.canvas,
      onSurface: AppColors.ink,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primarySoft,
      onPrimary: Colors.white,
      secondary: AppColors.mint,
      onSecondary: AppColors.ink,
      surface: AppColors.darkSurface,
      onSurface: AppColors.onDark,
      error: AppColors.ruby,
      onError: Colors.white,
      outline: AppColors.darkHairline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Convenience colour lookups that respect the active brightness.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cardColor =>
      isDark ? AppColors.darkSurface : AppColors.canvas;

  Color get softCanvas =>
      isDark ? AppColors.darkSurfaceElevated : AppColors.canvasSoft;

  Color get hairlineColor =>
      isDark ? AppColors.darkHairline : AppColors.hairline;

  Color get inkColor => isDark ? AppColors.onDark : AppColors.ink;

  Color get bodyColor => isDark ? AppColors.onDarkSoft : AppColors.body;

  Color get mutedColor => isDark ? AppColors.onDarkSoft : AppColors.muted;
}
