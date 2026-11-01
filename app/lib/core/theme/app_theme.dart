import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'appearance_settings.dart';

class AppTheme {
  /// Backward compatible default espresso dark theme.
  static ThemeData get darkTheme => buildTheme(const AppearanceSettings());

  /// Default light crema theme.
  static ThemeData get lightTheme =>
      buildTheme(const AppearanceSettings(themeMode: AppThemeMode.crema));

  /// Builds a ThemeData customized by [AppearanceSettings].
  static ThemeData buildTheme(
    AppearanceSettings settings, [
    Brightness? platformBrightness,
  ]) {
    final effectiveBrightness = switch (settings.themeMode) {
      AppThemeMode.espresso => Brightness.dark,
      AppThemeMode.crema => Brightness.light,
      AppThemeMode.highContrast => Brightness.dark,
      AppThemeMode.system => platformBrightness ?? Brightness.dark,
    };

    final isDark = effectiveBrightness == Brightness.dark;
    final isHighContrast = settings.themeMode == AppThemeMode.highContrast;

    final Color background;
    final Color surface;
    final Color textPrimary;
    final Color textMuted;
    final Color border;

    if (isHighContrast) {
      background = const Color(0xFF000000);
      surface = const Color(0xFF000000);
      textPrimary = const Color(0xFFFFFFFF);
      textMuted = const Color(0xFFE0E0E0);
      border = const Color(0xFFFFFFFF);
    } else if (isDark) {
      background = AppColors.backgroundDeep;
      surface = AppColors.surfaceCard;
      textPrimary = AppColors.textPrimary;
      textMuted = AppColors.textMuted;
      border = AppColors.surfaceHighlight;
    } else {
      // Crema light theme
      background = const Color(0xFFFBF9F5);
      surface = const Color(0xFFFFFFFF);
      textPrimary = const Color(0xFF1E1B19);
      textMuted = const Color(0xFF5E554D);
      border = const Color(0xFFE6DEC5);
    }

    final primaryAccent = settings.accentColor.colorFor(
      settings.themeMode,
      isDark: isDark,
    );

    // On-primary text color chosen to maximize contrast against the primary accent
    final whiteContrast = contrastRatio(const Color(0xFFFFFFFF), primaryAccent);
    final darkContrast = contrastRatio(const Color(0xFF141211), primaryAccent);
    final onPrimary = whiteContrast >= darkContrast
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF141211);

    final colorScheme = ColorScheme(
      brightness: effectiveBrightness,
      primary: primaryAccent,
      onPrimary: onPrimary,
      secondary: primaryAccent,
      onSecondary: onPrimary,
      surface: surface,
      onSurface: textPrimary,
      error: AppColors.alertRed,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: effectiveBrightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: BorderSide(
            color: isHighContrast ? border : border,
            width: isHighContrast ? 2.0 : 1.0,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primaryAccent),
        unselectedIconTheme: IconThemeData(color: textMuted),
        selectedLabelTextStyle: TextStyle(
          color: primaryAccent,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelTextStyle: TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: onPrimary,
          minimumSize: const Size(
            AppDimensions.preferredTouchTarget,
            AppDimensions.preferredTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            side: isHighContrast
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryAccent,
          side: BorderSide(color: primaryAccent, width: isHighContrast ? 2 : 1),
          minimumSize: const Size(
            AppDimensions.preferredTouchTarget,
            AppDimensions.preferredTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: onPrimary,
          minimumSize: const Size(
            AppDimensions.preferredTouchTarget,
            AppDimensions.preferredTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            side: isHighContrast
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isHighContrast ? Colors.black : surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(
            color: isHighContrast ? Colors.white : border,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(
            color: isHighContrast ? Colors.white : border,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.alertRed),
        ),
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.6)),
      ),
    );
  }

  /// Calculates WCAG 2.1 relative luminance for a color.
  static double relativeLuminance(Color color) {
    double channel(double value) {
      return value <= 0.03928
          ? value / 12.92
          : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  /// Calculates WCAG 2.1 contrast ratio between two colors (range 1:1 to 21:1).
  static double contrastRatio(Color c1, Color c2) {
    final l1 = relativeLuminance(c1);
    final l2 = relativeLuminance(c2);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }
}
