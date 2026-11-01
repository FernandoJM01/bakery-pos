import 'dart:convert';

import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_exceptions.dart';
import 'package:bakery_pos/features/sync/data/sync_worker.dart';
import 'package:bakery_pos/features/till_catalog/data/till_catalog_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/till_auth_service_test.dart' show FakeSecureStorageStore;

// Offline verifier for PIN 1234 (same fixture as the auth service tests).
const _verifier =
    r'$argon2id$v=19$m=65536,p=1,t=3$p6+vhCNw8VlT1Bnq34jEeg$cZv+IP6sdJhBnTqEB3+SsD8svzrLHXPiPpDEWJPp/54';

/// Counts what each push sends, in front of the fake server.
class _PushLog extends Interceptor {
  final batches = <List<String>>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path.endsWith('/v1/sync/push')) {
      final body = jsonDecode(jsonEncode(options.data)) as Map<String, dynamic>;
      batches.add([
        for (final r in body['records'] as List) (r as Map)['id'] as String,
      ]);
    }
    handler.next(options);
  }
}

void main() {
  late FakeApiInterceptor fake;
  late _PushLog log;
  late AppDatabase db;
  late SyncWorker worker;
  late Dio dio;
  var now = DateTime.utc(2026, 11, 1, 12);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    fake = FakeApiInterceptor();
    log = _PushLog();
    dio = Dio()..interceptors.addAll([log, fake]);
    db = AppDatabase(NativeDatabase.memory());
    final api = RestClient(dio).sync;
    worker = SyncWorker(
      db: db,
      api: api,
      catalog: TillCatalogRepository(db, api),
      clock: () => now,
    );
  });

  tearDown(() async {
    worker.dispose();
    await db.close();
  });

  Future<void> queue(String staffId, {Map<String, Object?>? payload}) => db
      .into(db.outboxEntries)
      .insert(
        OutboxEntriesCompanion.insert(
          id: 'r-${DateTime.now().microsecondsSinceEpoch}-$staffId',
          type: 'audit.offline_event',
          occurredAt: now,
          actorStaffId: Value(staffId),
          payload: jsonEncode(
            payload ?? {'action': 'auth.login_success', 'staffId': staffId},
          ),
        ),
      );

  test('C12: a network error leaves records pending and backs off 15, 30, 60, 60 s', () async {
    await queue('s1');
    fake.offline = true;
    expect(worker.nextDelay, const Duration(seconds: 15));
    final delays = <Duration>[];
    for (var i = 0; i < 4; i++) {
      expect(await worker.runCycle(), isFalse);
      delays.add(worker.nextDelay);
    }
    expect(delays.map((d) => d.inSeconds), [15, 30, 60, 60]);
    expect(worker.isOnline, isFalse);
    final rows = await db.select(db.outboxEntries).get();
    expect(rows.single.status, 'PENDING');
    expect(rows.single.attempts, 4);

    fake.offline = false;
    expect(await worker.runCycle(), isTrue);
    expect(worker.nextDelay, const Duration(seconds: 15));
    expect(worker.isOnline, isTrue);
    expect(await db.select(db.outboxEntries).get(), isEmpty);

    now = now.add(const Duration(seconds: 46));
    expect(
      worker.isOnline,
      isFalse,
      reason: 'online means a success within 45 s',
    );
  });

  test(
    'C12: a quarantined record stops being sent while the others continue',
    () async {
      await queue('s1');
      await queue(
        's2',
        payload: {
          'action': 'auth.login_success',
          'staffId': 's2',
          'pin': '1234',
        },
      );
      await queue('s3');
      expect(await worker.runCycle(), isTrue);
      expect(log.batches.single, hasLength(3));

      final left = await db.select(db.outboxEntries).get();
      expect(left.single.actorStaffId, 's2');
      expect(left.single.status, 'QUARANTINED');
      expect(left.single.lastErrorCode, 'SYNC_INVALID_PAYLOAD');

      await queue('s4');
      await worker.runCycle();
      expect(
        log.batches.last,
        hasLength(1),
        reason: 'only the new record is sent',
      );
      expect(await db.pendingOutbox(), isEmpty);
    },
  );

  test('records go oldest first in batches of at most 100', () async {
    for (var i = 0; i < 230; i++) {
      await db
          .into(db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: 'r${i.toString().padLeft(3, '0')}',
              type: 'audit.offline_event',
              occurredAt: now.add(Duration(seconds: 230 - i)),
              payload: jsonEncode({
                'action': 'auth.login_success',
                'staffId': 's',
              }),
            ),
          );
    }
    await worker.runCycle();
    expect(log.batches.map((b) => b.length), [100, 100, 30]);
    expect(log.batches.first.first, 'r229');
    expect(await db.select(db.outboxEntries).get(), isEmpty);
  });

  test('C11: 3 offline logins and 1 offline approval reach the server in one cycle after reconnecting', () async {
    final staff = StaffEntry(
      id: '0192e2b0-0030-7000-8000-000000000030',
      displayName: 'Ana',
      role: 'CASHIER',
      offlinePinVerifier: _verifier,
      pinUpdatedAt: DateTime.utc(2026),
    );
    await db.replaceStaffBundle(
      staff: [
        StaffEntriesCompanion.insert(
          id: staff.id,
          displayName: staff.displayName,
          role: staff.role,
          offlinePinVerifier: _verifier,
          pinUpdatedAt: DateTime.utc(2026),
        ),
      ],
      permissions: const [],
    );
    fake.offline = true;
    final auth = TillAuthService(
      restClient: RestClient(dio),
      database: db,
      secureStorage: SecureStorageService(FakeSecureStorageStore()),
      clock: () => now,
    );
    addTearDown(auth.dispose);

    expect(
      (await auth.loginWithPin(staff: staff, pin: '1234')).isOffline,
      isTrue,
    );
    await expectLater(
      auth.loginWithPin(staff: staff, pin: '9999'),
      throwsA(isA<TillAuthInvalidPinException>()),
    );
    expect(
      (await auth.loginWithPin(staff: staff, pin: '1234')).isOffline,
      isTrue,
    );
    await db.recordOfflineApproval(
      id: '0192e2b0-0aaa-7000-8000-000000000001',
      approverStaffId: fake.managerId,
      requesterStaffId: staff.id,
      action: 'sale.refund',
      reference: 'ticket-12',
      // Later than the logins, which all share `now`.
      createdAt: now.add(const Duration(minutes: 1)),
    );

    final queued = await db.pendingOutbox();
    expect(queued.map((r) => jsonDecode(r.payload)['action']), [
      'auth.login_success',
      'auth.login_failure',
      'auth.login_success',
      'auth.approval_granted',
    ]);
    for (final r in queued) {
      expect(
        r.payload.toLowerCase(),
        isNot(contains('pin"')),
        reason: 'no PIN in the outbox',
      );
    }
    expect(jsonDecode(queued.last.payload), {
      'action': 'auth.approval_granted',
      'staffId': staff.id,
      'approverStaffId': fake.managerId,
      'approvalAction': 'sale.refund',
      'reference': 'ticket-12',
    });

    expect(await worker.runCycle(), isFalse, reason: 'still offline');
    fake.offline = false;
    expect(await worker.runCycle(), isTrue);
    expect(fake.catalog.inbox.length, 4);
    expect(fake.catalog.inbox.values.every((s) => s == 'APPLIED'), isTrue);
    expect(await db.select(db.outboxEntries).get(), isEmpty);
  });

  test(
    'five wrong offline PINs queue the failures and one auth.locked',
    () async {
      final at = DateTime.utc(2026, 11, 1, 9);
      for (var i = 0; i < 5; i++) {
        await db.recordOfflinePinFailure('s1', at);
      }
      // A wrong approver PIN is counted but is not a login failure.
      await db.recordOfflinePinFailure('s2', at, isLogin: false);
      final actions = [
        for (final r in await db.pendingOutbox())
          jsonDecode(r.payload)['action'],
      ];
      expect(actions.where((a) => a == 'auth.login_failure'), hasLength(5));
      expect(actions.where((a) => a == 'auth.locked'), hasLength(1));
    },
  );
}
