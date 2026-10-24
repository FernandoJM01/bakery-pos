import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/branches/presentation/branches_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BranchesScreen', () {
    late Dio dio;
    late RestClient restClient;
    late FakeApiInterceptor fakeApi;

    setUp(() {
      fakeApi = FakeApiInterceptor();
      dio = Dio();
      dio.interceptors.add(fakeApi);
      restClient = RestClient(dio);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          restClientProvider.overrideWithValue(restClient),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BranchesScreen(),
        ),
      );
    }

    testWidgets('renders branch list from API', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('branches-table')), findsOneWidget);
      expect(find.text('SUC1'), findsOneWidget);
      expect(find.text('Sucursal Centro'), findsOneWidget);
      expect(find.text('SUC2'), findsOneWidget);
      expect(find.text('Sucursal Norte'), findsOneWidget);
      expect(find.text('Activa'), findsNWidgets(2));
    });

    testWidgets('creates a new branch via dialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('create-branch-button')));
      await tester.pumpAndSettle();

      expect(find.text('Nueva sucursal'), findsWidgets);

      // Try saving empty -> validation error
      await tester.tap(find.byKey(const Key('save-branch-button')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'El código debe tener entre 2 y 10 caracteres alfanuméricos en mayúsculas',
        ),
        findsOneWidget,
      );

      // Enter duplicate code -> conflict error
      await tester.enterText(
        find.byKey(const Key('branch-code-input')),
        'SUC1',
      );
      await tester.enterText(
        find.byKey(const Key('branch-name-input')),
        'Sucursal Duplicada',
      );
      await tester.tap(find.byKey(const Key('save-branch-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Ya existe una sucursal con ese código'),
        findsOneWidget,
      );

      // Enter unique code and save
      await tester.enterText(
        find.byKey(const Key('branch-code-input')),
        'SUC3',
      );
      await tester.enterText(
        find.byKey(const Key('branch-name-input')),
        'Sucursal Sur',
      );
      await tester.enterText(
        find.byKey(const Key('branch-address-input')),
        'Calzada del Valle 300',
      );
      await tester.tap(find.byKey(const Key('save-branch-button')));
      await tester.pumpAndSettle();

      // Dialog closed, new branch appears in table
      expect(find.text('SUC3'), findsOneWidget);
      expect(find.text('Sucursal Sur'), findsOneWidget);
      expect(find.text('Sucursal creada exitosamente'), findsOneWidget);
    });

    testWidgets('edits an existing branch via dialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('edit-branch-SUC1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit-branch-SUC1')));
      await tester.pumpAndSettle();

      expect(find.text('Editar sucursal'), findsOneWidget);
      expect(find.text('El código no se puede modificar'), findsOneWidget);

      // Modify name
      await tester.enterText(
        find.byKey(const Key('branch-name-input')),
        'Sucursal Centro Modificada',
      );
      await tester.tap(find.byKey(const Key('save-branch-button')));
      await tester.pumpAndSettle();

      // Dialog closed, updated name in table
      expect(find.text('Sucursal Centro Modificada'), findsOneWidget);
      expect(find.text('Sucursal actualizada exitosamente'), findsOneWidget);
    });
  });
}
