import 'package:bakery_pos/app.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/enrollment/presentation/enrollment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorageStore extends Fake implements FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => null;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}
}

void main() {
  testWidgets(
    'BakeryPosApp renders enrollment screen in till mode without token',
    (tester) async {
      final fakeStorage = SecureStorageService(_FakeSecureStorageStore());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageProvider.overrideWithValue(fakeStorage)],
          child: const BakeryPosApp(mode: AppMode.till),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(EnrollmentScreen), findsOneWidget);
      expect(find.byKey(const Key('enrollment-submit-button')), findsOneWidget);
    },
  );

  testWidgets('BakeryPosApp renders login placeholder in backoffice mode', (
    tester,
  ) async {
    final fakeStorage = SecureStorageService(_FakeSecureStorageStore());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [secureStorageProvider.overrideWithValue(fakeStorage)],
        child: const BakeryPosApp(mode: AppMode.backoffice),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byKey(const Key('mode-label')), findsOneWidget);
    expect(find.text('backoffice-login'), findsOneWidget);
  });
}
