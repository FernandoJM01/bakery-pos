import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/approval_models.dart';
import 'package:bakery_pos/features/auth/domain/offline_pin_verifier.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/auth/presentation/approval_dialog.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorageStore extends Fake implements FlutterSecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

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
  }) async {
    if (value != null) values[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.clear();
}

class FakeFastPinVerifier extends Fake implements OfflinePinVerifier {
  @override
  Future<bool> verify(String pin, String verifier) async => pin == '1234';
}

Widget createApprovalTestApp({
  required AppDatabase database,
  required SecureStorageService secureStorage,
  required RestClient restClient,
  required TillSession session,
  OfflinePinVerifier? verifier,
  required Widget Function(BuildContext) builder,
}) {
  return ProviderScope(
    overrides: [
      tillDatabaseProvider.overrideWithValue(database),
      secureStorageProvider.overrideWithValue(secureStorage),
      restClientProvider.overrideWithValue(restClient),
      tillSessionProvider.overrideWith(() => _TestSessionNotifier(session)),
      offlinePinVerifierProvider.overrideWithValue(
        verifier ?? FakeFastPinVerifier(),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('es', 'MX'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Builder(builder: builder)),
    ),
  );
}

class _TestSessionNotifier extends TillSessionNotifier {
  _TestSessionNotifier(this._session);
  final TillSession _session;

  @override
  TillSession? build() => _session;
}

void main() {
  group('Manager Approval Dialog Tests', () {
    late AppDatabase db;
    late FakeSecureStorageStore fakeStore;
    late SecureStorageService secureStorage;
    late RestClient restClient;

    // PIN '1234' with test salt
    const validVerifier =
        r'$argon2id$v=19$m=65536,t=3,p=1$dGVzdHNhbHQxMjM0$a3eQTmzY2EF7EnnZVEMeIqJEhBxWE2OCvFk+kud2a/4';

    final managerStaff = StaffEntriesCompanion.insert(
      id: '0192e2b0-0020-7000-8000-000000000020',
      displayName: 'Carlos (Gerente)',
      role: 'BRANCH_MANAGER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    final cashierStaff = StaffEntriesCompanion.insert(
      id: '0192e2b0-0030-7000-8000-000000000030',
      displayName: 'Ana (Cajera)',
      role: 'CASHIER',
      offlinePinVerifier: validVerifier,
      pinUpdatedAt: DateTime.utc(2026, 1, 1),
    );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      fakeStore = FakeSecureStorageStore();
      secureStorage = SecureStorageService(fakeStore);
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'))
        ..interceptors.add(FakeApiInterceptor());
      restClient = RestClient(dio);

      await db.replaceStaffBundle(
        staff: [managerStaff, cashierStaff],
        permissions: [
          RolePermissionsCompanion.insert(
            role: 'BRANCH_MANAGER',
            permissionKey: 'cash.open_drawer_no_sale',
          ),
          RolePermissionsCompanion.insert(
            role: 'CASHIER',
            permissionKey: 'sale.create',
          ),
        ],
      );
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Online approval success: returns OnlineApprovalResult', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cashierEntry = await db.getStaffById(
        '0192e2b0-0030-7000-8000-000000000030',
      );
      final cashierSession = TillSession(
        staff: cashierEntry!,
        permissions: const ['sale.create'],
        isOffline: false,
        accessToken: 'fake-access-token-jwt',
      );

      ApprovalResult? result;

      await tester.pumpWidget(
        createApprovalTestApp(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          session: cashierSession,
          builder: (context) {
            return ElevatedButton(
              key: const Key('open-dialog-btn'),
              onPressed: () async {
                result = await requestApproval(
                  context,
                  action: 'cash.open_drawer_no_sale',
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      );

      // Open dialog
      await tester.tap(find.byKey(const Key('open-dialog-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('manager-approval-dialog')), findsOneWidget);
      expect(find.text('Carlos (Gerente)'), findsOneWidget);

      // Enter PIN 1234
      await tester.tap(find.byKey(const Key('keypad-1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad-2')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad-3')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad-4')));
      await tester.pump();

      // Tap confirm
      await tester.tap(find.byKey(const Key('keypad-confirm')));
      await tester.pumpAndSettle();

      // Dialog dismissed, result returned
      expect(find.byKey(const Key('manager-approval-dialog')), findsNothing);
      expect(result, isA<OnlineApprovalResult>());
      final onlineResult = result as OnlineApprovalResult;
      expect(onlineResult.approvalToken, 'fake-approval-token-xyz');
      expect(onlineResult.action, 'cash.open_drawer_no_sale');
      expect(onlineResult.approverStaffId, managerStaff.id.value);
    });

    testWidgets('Wrong PIN shows error message and does not dismiss dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cashierEntry = await db.getStaffById(
        '0192e2b0-0030-7000-8000-000000000030',
      );
      final cashierSession = TillSession(
        staff: cashierEntry!,
        permissions: const ['sale.create'],
        isOffline: false,
        accessToken: 'fake-access-token-jwt',
      );

      await tester.pumpWidget(
        createApprovalTestApp(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          session: cashierSession,
          builder: (context) {
            return ElevatedButton(
              key: const Key('open-dialog-btn'),
              onPressed: () =>
                  requestApproval(context, action: 'cash.open_drawer_no_sale'),
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.byKey(const Key('open-dialog-btn')));
      await tester.pumpAndSettle();

      // Enter wrong PIN 5555
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('keypad-5')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('keypad-confirm')));
      await tester.pumpAndSettle();

      // Dialog is still open with error message
      expect(find.byKey(const Key('manager-approval-dialog')), findsOneWidget);
      expect(find.byKey(const Key('approval-error-message')), findsOneWidget);
      final l10n = await AppLocalizations.delegate.load(
        const Locale('es', 'MX'),
      );
      expect(find.text(l10n.approvalInvalidPin), findsOneWidget);
    });

    testWidgets(
      'Offline approval success: verifies PIN offline, records in DB, returns OfflineApprovalResult',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final cashierEntry = await db.getStaffById(
          '0192e2b0-0030-7000-8000-000000000030',
        );
        final offlineSession = TillSession(
          staff: cashierEntry!,
          permissions: const ['sale.create'],
          isOffline: true,
        );

        ApprovalResult? result;

        await tester.pumpWidget(
          createApprovalTestApp(
            database: db,
            secureStorage: secureStorage,
            restClient: restClient,
            session: offlineSession,
            builder: (context) {
              return ElevatedButton(
                key: const Key('open-dialog-btn'),
                onPressed: () async {
                  result = await requestApproval(
                    context,
                    action: 'cash.open_drawer_no_sale',
                    reference: 'drawer-ref-1',
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        );

        await tester.tap(find.byKey(const Key('open-dialog-btn')));
        await tester.pumpAndSettle();

        // Enter correct PIN 1234
        await tester.tap(find.byKey(const Key('keypad-1')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('keypad-2')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('keypad-3')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('keypad-4')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('keypad-confirm')));
        await tester.pumpAndSettle();

        expect(result, isA<OfflineApprovalResult>());
        final offlineResult = result as OfflineApprovalResult;
        expect(offlineResult.approverStaffId, managerStaff.id.value);
        expect(offlineResult.action, 'cash.open_drawer_no_sale');
        expect(offlineResult.reference, 'drawer-ref-1');

        // Check record persisted in database
        final approvals = await db.getOfflineApprovals();
        expect(approvals.length, 1);
        expect(approvals.first.id, offlineResult.id);
        expect(approvals.first.approverStaffId, managerStaff.id.value);
        expect(approvals.first.action, 'cash.open_drawer_no_sale');
        expect(approvals.first.reference, 'drawer-ref-1');
      },
    );

    testWidgets('Offline lockout: 5 wrong attempts locks approver', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cashierEntry = await db.getStaffById(
        '0192e2b0-0030-7000-8000-000000000030',
      );
      final offlineSession = TillSession(
        staff: cashierEntry!,
        permissions: const ['sale.create'],
        isOffline: true,
      );

      await tester.pumpWidget(
        createApprovalTestApp(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          session: offlineSession,
          builder: (context) {
            return ElevatedButton(
              key: const Key('open-dialog-btn'),
              onPressed: () =>
                  requestApproval(context, action: 'cash.open_drawer_no_sale'),
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.byKey(const Key('open-dialog-btn')));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(
        const Locale('es', 'MX'),
      );

      // Perform 5 wrong attempts
      for (var attempt = 1; attempt <= 5; attempt++) {
        await tester.tap(find.byKey(const Key('keypad-9')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('keypad-9')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('keypad-9')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('keypad-9')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('keypad-confirm')));
        await tester.pumpAndSettle();
      }

      // 5th attempt locks manager: message should be locked
      expect(find.text(l10n.approvalLocked), findsOneWidget);

      // Check lockout in database
      final lockout = await db.getLockout(managerStaff.id.value);
      expect(lockout, isNotNull);
      expect(lockout!.failedAttempts, 5);
      expect(lockout.lockedUntil, isNotNull);
    });

    testWidgets('Current user is excluded from approver list', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Manager is logged in and opens approval dialog for cash.open_drawer_no_sale
      final managerEntry = await db.getStaffById(
        '0192e2b0-0020-7000-8000-000000000020',
      );
      final managerSession = TillSession(
        staff: managerEntry!,
        permissions: const ['cash.open_drawer_no_sale'],
        isOffline: false,
      );

      await tester.pumpWidget(
        createApprovalTestApp(
          database: db,
          secureStorage: secureStorage,
          restClient: restClient,
          session: managerSession,
          builder: (context) {
            return ElevatedButton(
              key: const Key('open-dialog-btn'),
              onPressed: () =>
                  requestApproval(context, action: 'cash.open_drawer_no_sale'),
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.byKey(const Key('open-dialog-btn')));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(
        const Locale('es', 'MX'),
      );

      // Manager is excluded, so no eligible approvers remain
      expect(find.text(l10n.approvalNoApprovers), findsOneWidget);
      expect(
        find.byKey(Key('approval-staff-${managerStaff.id.value}')),
        findsNothing,
      );
    });
  });
}
