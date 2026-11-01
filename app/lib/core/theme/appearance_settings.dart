import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  espresso,
  crema,
  highContrast,
  system;

  String toJson() => name;

  static AppThemeMode fromJson(String? val) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AppThemeMode.espresso,
    );
  }
}

enum AppAccentColor {
  amber(
    darkColor: Color(0xFFE58A2B), // Amber warm golden
    lightColor: Color(0xFFB45309), // Rich amber (WCAG AA against cream)
    highContrastColor: Color(0xFFFFD700), // Gold
  ),
  wheat(
    darkColor: Color(0xFFD4A359), // Wheat / honey
    lightColor: Color(0xFF8A6000), // Deep wheat (WCAG AA)
    highContrastColor: Color(0xFFFFE066),
  ),
  terracotta(
    darkColor: Color(0xFFE06A3B), // Terracotta / cinnamon
    lightColor: Color(0xFFA83818), // Deep terracotta (WCAG AA)
    highContrastColor: Color(0xFFFF6F43),
  ),
  mint(
    darkColor: Color(0xFF2EBD85), // Fresh mint
    lightColor: Color(0xFF1B7A53), // Deep mint (WCAG AA)
    highContrastColor: Color(0xFF00FF9D),
  ),
  berry(
    darkColor: Color(0xFF5C8DEF), // Berry blue
    lightColor: Color(0xFF1D58B8), // Deep berry (WCAG AA)
    highContrastColor: Color(0xFF60A5FA),
  );

  const AppAccentColor({
    required this.darkColor,
    required this.lightColor,
    required this.highContrastColor,
  });

  final Color darkColor;
  final Color lightColor;
  final Color highContrastColor;

  Color colorFor(AppThemeMode mode, {bool isDark = true}) {
    switch (mode) {
      case AppThemeMode.espresso:
        return darkColor;
      case AppThemeMode.crema:
        return lightColor;
      case AppThemeMode.highContrast:
        return highContrastColor;
      case AppThemeMode.system:
        return isDark ? darkColor : lightColor;
    }
  }

  String toJson() => name;

  static AppAccentColor fromJson(String? val) {
    return AppAccentColor.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AppAccentColor.amber,
    );
  }
}

enum AppTextScale {
  normal(1.0),
  large(1.15),
  extraLarge(1.30);

  const AppTextScale(this.factor);
  final double factor;

  String toJson() => name;

  static AppTextScale fromJson(String? val) {
    return AppTextScale.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AppTextScale.normal,
    );
  }
}

enum ProductButtonStyle {
  photoAndName,
  nameOnly;

  String toJson() => name;

  static ProductButtonStyle fromJson(String? val) {
    return ProductButtonStyle.values.firstWhere(
      (e) => e.name == val,
      orElse: () => ProductButtonStyle.photoAndName,
    );
  }
}

class AppearanceSettings {
  const AppearanceSettings({
    this.themeMode = AppThemeMode.espresso,
    this.accentColor = AppAccentColor.amber,
    this.textScale = AppTextScale.normal,
    this.buttonStyle = ProductButtonStyle.photoAndName,
  });

  final AppThemeMode themeMode;
  final AppAccentColor accentColor;
  final AppTextScale textScale;
  final ProductButtonStyle buttonStyle;

  AppearanceSettings copyWith({
    AppThemeMode? themeMode,
    AppAccentColor? accentColor,
    AppTextScale? textScale,
    ProductButtonStyle? buttonStyle,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      textScale: textScale ?? this.textScale,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.toJson(),
    'accentColor': accentColor.toJson(),
    'textScale': textScale.toJson(),
    'buttonStyle': buttonStyle.toJson(),
  };

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) {
    return AppearanceSettings(
      themeMode: AppThemeMode.fromJson(json['themeMode'] as String?),
      accentColor: AppAccentColor.fromJson(json['accentColor'] as String?),
      textScale: AppTextScale.fromJson(json['textScale'] as String?),
      buttonStyle: ProductButtonStyle.fromJson(json['buttonStyle'] as String?),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppearanceSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          accentColor == other.accentColor &&
          textScale == other.textScale &&
          buttonStyle == other.buttonStyle;

  @override
  int get hashCode =>
      themeMode.hashCode ^
      accentColor.hashCode ^
      textScale.hashCode ^
      buttonStyle.hashCode;
}

typedef SettingsSaveCallback = Future<void> Function(
  AppearanceSettings settings,
);

final appearanceSettingsSaveCallbackProvider = Provider<SettingsSaveCallback?>(
  (ref) => null,
);

final appearanceSettingsProvider =
    NotifierProvider<AppearanceSettingsNotifier, AppearanceSettings>(
      AppearanceSettingsNotifier.new,
    );

class AppearanceSettingsNotifier extends Notifier<AppearanceSettings> {
  AppearanceSettingsNotifier([this.initialSettings]);

  final AppearanceSettings? initialSettings;

  @override
  AppearanceSettings build() => initialSettings ?? const AppearanceSettings();

  Future<void> updateSettings(AppearanceSettings newSettings) async {
    state = newSettings;
    final callback = ref.read(appearanceSettingsSaveCallbackProvider);
    if (callback != null) {
      await callback(newSettings);
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      updateSettings(state.copyWith(themeMode: mode));

  Future<void> setAccentColor(AppAccentColor color) =>
      updateSettings(state.copyWith(accentColor: color));

  Future<void> setTextScale(AppTextScale scale) =>
      updateSettings(state.copyWith(textScale: scale));

  Future<void> setButtonStyle(ProductButtonStyle style) =>
      updateSettings(state.copyWith(buttonStyle: style));
}
