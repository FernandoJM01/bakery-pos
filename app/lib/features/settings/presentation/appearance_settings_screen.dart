import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/appearance_settings.dart';
import '../../../l10n/app_localizations.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appearanceSettingsProvider);
    final notifier = ref.read(appearanceSettingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsAppearanceBreadcrumb,
          key: const Key('appearance-screen-title'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;

          final settingsList = SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Theme selection
                Text(
                  l10n.settingsTheme,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildThemeSelector(context, settings, notifier, l10n),
                const SizedBox(height: AppDimensions.paddingLarge),

                // 2. Accent color selection
                Text(
                  l10n.settingsAccentColor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildAccentSelector(context, settings, notifier, l10n),
                const SizedBox(height: AppDimensions.paddingLarge),

                // 3. Text size selection
                Text(
                  l10n.settingsTextSize,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildTextScaleSelector(context, settings, notifier, l10n),
                const SizedBox(height: AppDimensions.paddingLarge),

                // 4. Product button style selection
                Text(
                  l10n.settingsButtonStyle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildButtonStyleSelector(context, settings, notifier, l10n),
              ],
            ),
          );

          final previewPanel = Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: _buildPreviewPanel(context, settings, l10n),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: settingsList),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(child: previewPanel),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  previewPanel,
                  const Divider(height: 1, thickness: 1),
                  settingsList,
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    AppearanceSettings settings,
    AppearanceSettingsNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final options = [
      (
        AppThemeMode.espresso,
        l10n.settingsThemeEspresso,
        l10n.settingsThemeEspressoDesc,
        'theme-option-espresso',
        Icons.dark_mode_rounded,
      ),
      (
        AppThemeMode.crema,
        l10n.settingsThemeCrema,
        l10n.settingsThemeCremaDesc,
        'theme-option-crema',
        Icons.light_mode_rounded,
      ),
      (
        AppThemeMode.highContrast,
        l10n.settingsThemeHighContrast,
        l10n.settingsThemeHighContrastDesc,
        'theme-option-high-contrast',
        Icons.contrast_rounded,
      ),
      (
        AppThemeMode.system,
        l10n.settingsThemeSystem,
        l10n.settingsThemeSystemDesc,
        'theme-option-system',
        Icons.brightness_auto_rounded,
      ),
    ];

    return Wrap(
      spacing: AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingMedium,
      children: [
        for (final (mode, title, desc, key, icon) in options)
          SizedBox(
            width: 260,
            child: InkWell(
              key: Key(key),
              onTap: () => notifier.setThemeMode(mode),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppDimensions.preferredTouchTarget,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  border: Border.all(
                    color: settings.themeMode == mode
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: settings.themeMode == mode ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: settings.themeMode == mode
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                      size: 24,
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: settings.themeMode == mode
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          Text(
                            desc,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (settings.themeMode == mode)
                      Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccentSelector(
    BuildContext context,
    AppearanceSettings settings,
    AppearanceSettingsNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final options = [
      (AppAccentColor.amber, l10n.settingsAccentAmber, 'accent-option-amber'),
      (AppAccentColor.wheat, l10n.settingsAccentWheat, 'accent-option-wheat'),
      (
        AppAccentColor.terracotta,
        l10n.settingsAccentTerracotta,
        'accent-option-terracotta',
      ),
      (AppAccentColor.mint, l10n.settingsAccentMint, 'accent-option-mint'),
      (AppAccentColor.berry, l10n.settingsAccentBerry, 'accent-option-berry'),
    ];

    return Wrap(
      spacing: AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingMedium,
      children: [
        for (final (accent, label, key) in options)
          InkWell(
            key: Key(key),
            onTap: () => notifier.setAccentColor(accent),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.preferredTouchTarget,
                minWidth: 100,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: settings.accentColor == accent
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: settings.accentColor == accent ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent.colorFor(
                        settings.themeMode,
                        isDark: isDark,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: settings.accentColor == accent
                            ? Colors.white
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: settings.accentColor == accent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextScaleSelector(
    BuildContext context,
    AppearanceSettings settings,
    AppearanceSettingsNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final options = [
      (AppTextScale.normal, l10n.settingsTextSizeNormal, 'text-scale-normal'),
      (AppTextScale.large, l10n.settingsTextSizeLarge, 'text-scale-large'),
      (
        AppTextScale.extraLarge,
        l10n.settingsTextSizeExtraLarge,
        'text-scale-extra-large',
      ),
    ];

    return Wrap(
      spacing: AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingMedium,
      children: [
        for (final (scale, label, key) in options)
          InkWell(
            key: Key(key),
            onTap: () => notifier.setTextScale(scale),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.preferredTouchTarget,
                minWidth: 120,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: settings.textScale == scale
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: settings.textScale == scale ? 2.0 : 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: settings.textScale == scale
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: settings.textScale == scale
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildButtonStyleSelector(
    BuildContext context,
    AppearanceSettings settings,
    AppearanceSettingsNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final options = [
      (
        ProductButtonStyle.photoAndName,
        l10n.settingsButtonStylePhotoAndName,
        'button-style-photo-and-name',
        Icons.image_outlined,
      ),
      (
        ProductButtonStyle.nameOnly,
        l10n.settingsButtonStyleNameOnly,
        'button-style-name-only',
        Icons.text_fields_rounded,
      ),
    ];

    return Wrap(
      spacing: AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingMedium,
      children: [
        for (final (style, label, key, icon) in options)
          InkWell(
            key: Key(key),
            onTap: () => notifier.setButtonStyle(style),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.preferredTouchTarget,
                minWidth: 160,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: settings.buttonStyle == style
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: settings.buttonStyle == style ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: settings.buttonStyle == style
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: settings.buttonStyle == style
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: settings.buttonStyle == style
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewPanel(
    BuildContext context,
    AppearanceSettings settings,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final primaryAccent = theme.colorScheme.primary;

    return Card(
      key: const Key('appearance-preview-panel'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility_outlined, color: primaryAccent),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  l10n.settingsPreview,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            // Mock Product Tile
            Container(
              key: const Key('preview-product-tile'),
              width: 220,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (settings.buttonStyle == ProductButtonStyle.photoAndName)
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.bakery_dining_rounded,
                          size: 48,
                          color: primaryAccent,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsPreviewProductName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.settingsPreviewProductPrice,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            // Sample Accent Action Button
            ElevatedButton.icon(
              key: const Key('preview-sample-button'),
              onPressed: () {},
              icon: const Icon(Icons.touch_app_rounded),
              label: Text(l10n.settingsPreviewSampleButton),
            ),
          ],
        ),
      ),
    );
  }
}
