import 'package:bakery_pos/core/theme/app_theme.dart';
import 'package:bakery_pos/core/theme/appearance_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme Contrast Checks (WCAG AA & AAA)', () {
    test('Espresso theme text contrast meets WCAG requirements', () {
      final theme = AppTheme.buildTheme(
        const AppearanceSettings(themeMode: AppThemeMode.espresso),
      );

      final bg = theme.scaffoldBackgroundColor;
      final surface = theme.colorScheme.surface;
      final text = theme.colorScheme.onSurface;

      final textOnBgRatio = AppTheme.contrastRatio(text, bg);
      final textOnSurfaceRatio = AppTheme.contrastRatio(text, surface);

      expect(
        textOnBgRatio,
        greaterThanOrEqualTo(7.0),
        reason:
            'Espresso primary text on background must meet WCAG AAA (>= 7.0)',
      );
      expect(
        textOnSurfaceRatio,
        greaterThanOrEqualTo(7.0),
        reason: 'Espresso primary text on surface must meet WCAG AAA (>= 7.0)',
      );
    });

    test('Crema theme text contrast meets WCAG requirements', () {
      final theme = AppTheme.buildTheme(
        const AppearanceSettings(themeMode: AppThemeMode.crema),
      );

      final bg = theme.scaffoldBackgroundColor;
      final surface = theme.colorScheme.surface;
      final text = theme.colorScheme.onSurface;

      final textOnBgRatio = AppTheme.contrastRatio(text, bg);
      final textOnSurfaceRatio = AppTheme.contrastRatio(text, surface);

      expect(
        textOnBgRatio,
        greaterThanOrEqualTo(7.0),
        reason: 'Crema primary text on background must meet WCAG AAA (>= 7.0)',
      );
      expect(
        textOnSurfaceRatio,
        greaterThanOrEqualTo(7.0),
        reason: 'Crema primary text on surface must meet WCAG AAA (>= 7.0)',
      );
    });

    test('Alto Contraste theme meets WCAG AAA maximum contrast', () {
      final theme = AppTheme.buildTheme(
        const AppearanceSettings(themeMode: AppThemeMode.highContrast),
      );

      final bg = theme.scaffoldBackgroundColor;
      final text = theme.colorScheme.onSurface;

      final ratio = AppTheme.contrastRatio(text, bg);
      expect(
        ratio,
        greaterThanOrEqualTo(20.0),
        reason: 'High contrast theme must approach 21.0:1 pure black and white',
      );
    });

    test('All 5 accent colors meet WCAG contrast for buttons across all themes', () {
      final themes = [
        AppThemeMode.espresso,
        AppThemeMode.crema,
        AppThemeMode.highContrast,
      ];

      for (final mode in themes) {
        for (final accent in AppAccentColor.values) {
          final settings = AppearanceSettings(
            themeMode: mode,
            accentColor: accent,
          );
          final theme = AppTheme.buildTheme(settings);

          final primary = theme.colorScheme.primary;
          final onPrimary = theme.colorScheme.onPrimary;

          final onPrimaryRatio = AppTheme.contrastRatio(onPrimary, primary);
          expect(
            onPrimaryRatio,
            greaterThanOrEqualTo(4.5),
            reason:
                'Text on primary button for ${accent.name} in ${mode.name} mode must meet WCAG AA (>= 4.5)',
          );
        }
      }
    });
  });
}
