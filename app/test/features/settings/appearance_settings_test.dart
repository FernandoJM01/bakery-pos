import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/theme/app_dimensions.dart';
import 'package:bakery_pos/core/theme/appearance_settings.dart';
import 'package:bakery_pos/features/settings/data/till_appearance_repository.dart';
import 'package:bakery_pos/features/settings/presentation/appearance_settings_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppearanceSettings domain and serialization', () {
    test('roundtrips JSON serialization cleanly', () {
      const original = AppearanceSettings(
        themeMode: AppThemeMode.crema,
        accentColor: AppAccentColor.mint,
        textScale: AppTextScale.large,
        buttonStyle: ProductButtonStyle.nameOnly,
      );

      final json = original.toJson();
      final restored = AppearanceSettings.fromJson(json);

      expect(restored, original);
      expect(restored.themeMode, AppThemeMode.crema);
      expect(restored.accentColor, AppAccentColor.mint);
      expect(restored.textScale, AppTextScale.large);
      expect(restored.buttonStyle, ProductButtonStyle.nameOnly);
    });

    test('falls back to default values for empty or null JSON', () {
      final restored = AppearanceSettings.fromJson({});
      expect(restored.themeMode, AppThemeMode.espresso);
      expect(restored.accentColor, AppAccentColor.amber);
      expect(restored.textScale, AppTextScale.normal);
      expect(restored.buttonStyle, ProductButtonStyle.photoAndName);
    });
  });

  group('TillAppearanceRepository with AppDatabase', () {
    late AppDatabase db;
    late TillAppearanceRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = TillAppearanceRepository(db);
    });

    tearDown(() => db.close());

    test('returns null when no settings are saved yet', () async {
      final settings = await repository.loadSettings();
      expect(settings, isNull);
    });

    test('saves settings to database and restores them identically', () async {
      const toSave = AppearanceSettings(
        themeMode: AppThemeMode.highContrast,
        accentColor: AppAccentColor.terracotta,
        textScale: AppTextScale.extraLarge,
        buttonStyle: ProductButtonStyle.nameOnly,
      );

      await repository.saveSettings(toSave);
      final loaded = await repository.loadSettings();

      expect(loaded, toSave);
    });
  });

  group('AppearanceSettingsScreen Widget Tests', () {
    Widget buildTestWidget({
      AppearanceSettings initialSettings = const AppearanceSettings(),
      void Function(AppearanceSettings)? onSave,
    }) {
      return ProviderScope(
        overrides: [
          appearanceSettingsProvider.overrideWith(
            () => AppearanceSettingsNotifier(initialSettings),
          ),
          if (onSave != null)
            appearanceSettingsSaveCallbackProvider.overrideWith(
              (ref) =>
                  (settings) async => onSave(settings),
            ),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppearanceSettingsScreen(),
        ),
      );
    }

    testWidgets('renders all sections, preview panel, and 56dp touch targets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Ajustes · Apariencia'), findsOneWidget);

      // 4 Theme options
      final themeKeys = [
        'theme-option-espresso',
        'theme-option-crema',
        'theme-option-high-contrast',
        'theme-option-system',
      ];
      for (final key in themeKeys) {
        final finder = find.byKey(Key(key));
        expect(finder, findsOneWidget);
        final size = tester.getSize(finder);
        expect(
          size.height,
          greaterThanOrEqualTo(AppDimensions.preferredTouchTarget),
          reason: '$key must have height >= 56 dp',
        );
      }

      // 5 Accent options
      final accentKeys = [
        'accent-option-amber',
        'accent-option-wheat',
        'accent-option-terracotta',
        'accent-option-mint',
        'accent-option-berry',
      ];
      for (final key in accentKeys) {
        final finder = find.byKey(Key(key));
        expect(finder, findsOneWidget);
        final size = tester.getSize(finder);
        expect(
          size.height,
          greaterThanOrEqualTo(AppDimensions.preferredTouchTarget),
          reason: '$key must have height >= 56 dp',
        );
      }

      // 3 Text Scale options
      final scaleKeys = [
        'text-scale-normal',
        'text-scale-large',
        'text-scale-extra-large',
      ];
      for (final key in scaleKeys) {
        final finder = find.byKey(Key(key));
        expect(finder, findsOneWidget);
        final size = tester.getSize(finder);
        expect(
          size.height,
          greaterThanOrEqualTo(AppDimensions.preferredTouchTarget),
          reason: '$key must have height >= 56 dp',
        );
      }

      // 2 Button Style options
      final styleKeys = [
        'button-style-photo-and-name',
        'button-style-name-only',
      ];
      for (final key in styleKeys) {
        final finder = find.byKey(Key(key));
        expect(finder, findsOneWidget);
        final size = tester.getSize(finder);
        expect(
          size.height,
          greaterThanOrEqualTo(AppDimensions.preferredTouchTarget),
          reason: '$key must have height >= 56 dp',
        );
      }

      // Preview panel
      expect(find.byKey(const Key('appearance-preview-panel')), findsOneWidget);
      expect(find.text('Concha de vainilla'), findsOneWidget);
      expect(find.text('\$15.00'), findsOneWidget);
      expect(find.byKey(const Key('preview-sample-button')), findsOneWidget);
    });

    testWidgets(
      'switching theme, accent, scale, and style updates state immediately and invokes save',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        AppearanceSettings? lastSaved;

        await tester.pumpWidget(
          buildTestWidget(
            onSave: (settings) {
              lastSaved = settings;
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Switch theme to Crema
        await tester.tap(find.byKey(const Key('theme-option-crema')));
        await tester.pumpAndSettle();

        expect(lastSaved?.themeMode, AppThemeMode.crema);

        // 2. Switch accent to Mint
        await tester.tap(find.byKey(const Key('accent-option-mint')));
        await tester.pumpAndSettle();

        expect(lastSaved?.accentColor, AppAccentColor.mint);

        // 3. Switch button style to name only
        await tester.tap(find.byKey(const Key('button-style-name-only')));
        await tester.pumpAndSettle();

        expect(lastSaved?.buttonStyle, ProductButtonStyle.nameOnly);

        // 4. Switch text scale to large
        await tester.tap(find.byKey(const Key('text-scale-large')));
        await tester.pumpAndSettle();

        expect(lastSaved?.textScale, AppTextScale.large);
      },
    );

    testWidgets(
      'choice survives restart by loading saved configuration from repository',
      (tester) async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(() => db.close());
        final repo = TillAppearanceRepository(db);

        // Save a custom preference (Crema + Terracotta + NameOnly)
        const customSettings = AppearanceSettings(
          themeMode: AppThemeMode.crema,
          accentColor: AppAccentColor.terracotta,
          textScale: AppTextScale.large,
          buttonStyle: ProductButtonStyle.nameOnly,
        );
        await repo.saveSettings(customSettings);

        // Restart: load from repo into fresh provider
        final loadedSettings = await repo.loadSettings();
        expect(loadedSettings, isNotNull);

        await tester.pumpWidget(
          buildTestWidget(initialSettings: loadedSettings!),
        );
        await tester.pumpAndSettle();

        // Verify Crema is selected
        expect(
          find.descendant(
            of: find.byKey(const Key('theme-option-crema')),
            matching: find.byIcon(Icons.check_circle_rounded),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
