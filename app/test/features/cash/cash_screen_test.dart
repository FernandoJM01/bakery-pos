import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/approval_models.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/cash/data/shift_repository.dart';
import 'package:bakery_pos/features/cash/presentation/cash_screen.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:bakery_pos/features/sale/presentation/discount_dialog.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sale/sale_test_data.dart';

class _Session extends TillSessionNotifier {
  _Session(this.value);
  final TillSession value;
  @override
  TillSession? build() => value;
}

void main() {
  late AppDatabase db;
  final approvals = <String>[];
  ApprovalResult? approval;

  TillSession sessionOf(StaffEntry staff, List<String> permissions) =>
      TillSession(staff: staff, permissions: permissions, isOffline: true);
  const cashierPerms = ['sale.create', 'cash.open_shift', 'cash.close_shift'];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    approvals.clear();
    approval = null;
  });
  tearDown(() => db.close());

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await t.pump();
    }
  }

  Future<void> pumpCash(WidgetTester t, TillSession session) async {
    t.view.physicalSize = const Size(1280, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          tillSessionProvider.overrideWith(() => _Session(session)),
          enrolledBranchNameProvider.overrideWith((_) async => 'Centro'),
          saleClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 11, 2, 15, 30),
          ),
          approvalRequesterProvider.overrideWithValue((
            context, {
            required action,
            reference,
          }) async {
            approvals.add(action);
            return approval;
          }),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CashScreen()),
        ),
      ),
    );
    await settle(t);
  }

  /// Lets the live queries of the disposed tree finish.
  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  Future<void> tapKey(WidgetTester t, String key) async {
    await t.ensureVisible(find.byKey(Key(key)).first);
    await t.pump();
    await t.runAsync(() => t.tap(find.byKey(Key(key)).first));
    await settle(t);
  }

  Future<void> openShift() => ShiftRepository(db).open(
    staff: cashier,
    count: const {20000: 3},
    now: DateTime.utc(2026, 11, 2),
  );

  testWidgets('a cashier counts the float and opens the shift', (t) async {
    await pumpCash(t, sessionOf(cashier, cashierPerms));
    await t.enterText(find.byKey(const Key('count-50000')), '2');
    await t.enterText(find.byKey(const Key('count-100')), '3');
    await t.pump();
    expect(find.text(r'Total: $1,003.00'), findsOneWidget);
    await tapKey(t, 'count-submit');
    expect(find.byKey(const Key('shift-open')), findsOneWidget);
    final shift = await t.runAsync(() => db.select(db.localShifts).getSingle());
    expect(shift!.floatCents, 100300);
    await finish(t);
  });

  testWidgets('E4: a cashier\'s movement asks for a manager; refused without', (
    t,
  ) async {
    await t.runAsync(openShift);
    await pumpCash(t, sessionOf(cashier, cashierPerms));
    await tapKey(t, 'cash-out');
    await t.enterText(find.byKey(const Key('movement-amount')), '100');
    await t.pump();
    await tapKey(t, 'movement-reason-BANK_DROP');
    await tapKey(t, 'movement-save');
    expect(approvals, ['cash.movement']);
    expect(find.byKey(const Key('movement-error')), findsOneWidget);
    expect(
      await t.runAsync(() => db.select(db.localCashMovements).get()),
      isEmpty,
    );

    approval = OfflineApprovalResult(
      id: 'a',
      approverStaffId: manager.id,
      requesterStaffId: cashier.id,
      action: 'cash.movement',
      createdAt: DateTime.utc(2026),
    );
    await tapKey(t, 'movement-save');
    final m = await t.runAsync(
      () => db.select(db.localCashMovements).getSingle(),
    );
    expect(m!.amountCents, 10000);
    expect(m.approverStaffId, manager.id);
    await finish(t);
  });

  testWidgets(
    'E5: nothing shows the expected amount before the count is confirmed',
    (t) async {
      await t.runAsync(openShift);
      await pumpCash(t, sessionOf(cashier, cashierPerms));
      expect(find.text(r'$600.00'), findsNothing);
      await tapKey(t, 'cash-close');

      // The float itself shows on the panel behind; the dialog shows no amount.
      final dialog = find.byType(BlindCloseDialog);
      expect(
        find.descendant(
          of: dialog,
          matching: find.byKey(const Key('close-expected')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: dialog, matching: find.text(r'$600.00')),
        findsNothing,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Esperado')),
        findsNothing,
      );

      await t.enterText(find.byKey(const Key('count-20000')), '3');
      await t.pump();
      await tapKey(t, 'count-submit');
      // The confirmation still shows only what was counted.
      expect(find.byKey(const Key('close-expected')), findsNothing);
      await tapKey(t, 'close-confirm');

      expect(
        t.widget<Text>(find.byKey(const Key('close-expected'))).data,
        r'$600.00',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('close-difference'))).data,
        r'$0.00',
      );
      await tapKey(t, 'close-see-z');
      expect(find.byKey(const Key('z-report')), findsOneWidget);
    },
  );

  testWidgets('E7: a flagged close needs a note before it syncs', (t) async {
    await t.runAsync(openShift);
    await pumpCash(t, sessionOf(cashier, cashierPerms));
    await tapKey(t, 'cash-close');
    await t.enterText(find.byKey(const Key('count-20000')), '2');
    await t.pump();
    await tapKey(t, 'count-submit');
    await tapKey(t, 'close-confirm');
    expect(find.byKey(const Key('close-flagged')), findsWidgets);
    await tapKey(t, 'close-to-note');

    Future<List<String>> types() async => [
      for (final r in await db.select(db.outboxEntries).get()) r.type,
    ];
    expect(await t.runAsync(types), isNot(contains('shift.closed')));

    await t.enterText(find.byKey(const Key('close-note')), 'Faltó un billete');
    await t.pump();
    await tapKey(t, 'close-note-save');
    expect(await t.runAsync(types), contains('shift.closed'));
    final rows = await t.runAsync(() => db.select(db.outboxEntries).get());
    final closed = rows!.firstWhere((r) => r.type == 'shift.closed');
    expect((jsonDecode(closed.payload) as Map)['note'], 'Faltó un billete');
    await finish(t);
  });
}
