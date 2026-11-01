import 'dart:typed_data';

import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/approval_models.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:bakery_pos/features/sale/presentation/discount_dialog.dart';
import 'package:bakery_pos/features/sale/presentation/sale_screen.dart';
import 'package:bakery_pos/features/till_catalog/data/photo_cache.dart';
import 'package:bakery_pos/features/till_catalog/data/till_catalog_repository.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sale_test_data.dart';

class _NoPhotos implements PhotoCache {
  @override
  Future<Uint8List?> get(String photoId) async => null;
}

class _Session extends TillSessionNotifier {
  _Session(this._session);
  final TillSession _session;
  @override
  TillSession? build() => _session;
}

TillSession sessionOf(StaffEntry staff, List<String> permissions) =>
    TillSession(staff: staff, permissions: permissions, isOffline: true);

const cashierPermissions = [
  'sale.create',
  'sale.void_line_before_payment',
  'sale.discount_within_limit',
];

void main() {
  late AppDatabase db;
  late List<String> approvalsAsked;
  ApprovalResult? approval;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    approvalsAsked = [];
    approval = null;
  });
  tearDown(() => db.close());

  Future<void> pumpSale(WidgetTester tester, TillSession session) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() => seedTill(db));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          tillCatalogRepositoryProvider.overrideWithValue(
            TillCatalogRepository(db, RestClient(Dio()).sync),
          ),
          photoCacheProvider.overrideWithValue(_NoPhotos()),
          tillSessionProvider.overrideWith(() => _Session(session)),
          enrolledBranchNameProvider.overrideWith(
            (_) async => 'Sucursal Centro',
          ),
          saleClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 11, 2, 15, 30),
          ),
          approvalRequesterProvider.overrideWithValue((
            context, {
            required action,
            reference,
          }) async {
            approvalsAsked.add(action);
            return approval;
          }),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SaleScreen()),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets(
    'D1: three items paid with exact cash take 3 taps and show the receipt',
    (tester) async {
      await pumpSale(tester, sessionOf(cashier, cashierPermissions));
      await tester.tap(find.text('Concha'));
      await tester.tap(find.text('Galletas'));
      await tester.tap(find.text('Pastel'));
      await tester.pump();
      expect(find.byKey(const Key('ticket-total')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('ticket-total'))).data,
        r'$45.00',
      );

      var taps = 0;
      Future<void> tap(String key) async {
        taps++;
        await tester.runAsync(() => tester.tap(find.byKey(Key(key))));
        await settle(tester);
      }

      await tap('ticket-pay');
      await tap('payment-exact');
      await tap('payment-finish');
      expect(taps, 3);

      expect(find.byKey(const Key('receipt')), findsOneWidget);
      expect(find.text('Folio SUC1-02-000001'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('receipt-total'))).data,
        r'$45.00',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('receipt-change'))).data,
        r'$0.00',
      );
      expect(find.text('Sucursal Centro'), findsOneWidget);
      expect(find.text('IVA incluido'), findsOneWidget);

      await tester.tap(find.byKey(const Key('receipt-new-sale')));
      await settle(tester);
      expect(find.byKey(const Key('ticket-empty')), findsOneWidget);
      final outbox = await tester.runAsync(
        () => db.select(db.outboxEntries).get(),
      );
      expect(outbox!.single.type, 'sale.completed');
    },
  );

  testWidgets(
    'D4: a 10% line discount and a \$5.00 ticket discount charge the reduced total',
    (tester) async {
      await pumpSale(tester, sessionOf(cashier, cashierPermissions));
      await tester.tap(find.text('Concha'));
      await tester.tap(find.text('Concha'));
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Galletas'));
      }
      await tester.tap(find.text('Pastel'));
      await tester.pump();

      // 10% on the conchas.
      await tester.tap(find.byKey(const Key('ticket-line-1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('line-discount')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('discount-value')), '10');
      await tester.tap(find.byKey(const Key('discount-reason-PROMOTION')));
      await tester.pump();
      await tester.runAsync(
        () => tester.tap(find.byKey(const Key('discount-apply'))),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('line-done')));
      await settle(tester);

      // $5.00 off the ticket.
      await tester.tap(find.byKey(const Key('ticket-discount')));
      await settle(tester);
      await tester.tap(find.text(r'$'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('discount-value')), '5');
      await tester.tap(
        find.byKey(const Key('discount-reason-FREQUENT_CUSTOMER')),
      );
      await tester.pump();
      await tester.runAsync(
        () => tester.tap(find.byKey(const Key('discount-apply'))),
      );
      await settle(tester);

      expect(approvalsAsked, isEmpty);
      expect(
        tester.widget<Text>(find.byKey(const Key('ticket-total'))).data,
        r'$68.00',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('ticket-discounts'))).data,
        r'−$8.00',
      );

      await tester.runAsync(
        () => tester.tap(find.byKey(const Key('ticket-pay'))),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('payment-bill-10000')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('payment-change'))).data,
        r'$32.00',
      );
      await tester.runAsync(
        () => tester.tap(find.byKey(const Key('payment-finish'))),
      );
      await settle(tester);

      expect(
        tester.widget<Text>(find.byKey(const Key('receipt-total'))).data,
        r'$68.00',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('receipt-line-discount-1')))
            .data,
        r'−$3.00',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('receipt-ticket-discount')))
            .data,
        r'−$5.00',
      );
      final sale = await tester.runAsync(
        () => db.select(db.localSales).getSingle(),
      );
      expect(sale!.totalCents, 6800);
      expect(sale.discountCents, 800);
    },
  );

  Future<void> giveFifteenPercent(WidgetTester tester) async {
    await tester.tap(find.text('Pastel'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('ticket-discount')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('discount-value')), '15');
    await tester.tap(find.byKey(const Key('discount-reason-DAMAGED')));
    await tester.pump();
    expect(find.byKey(const Key('discount-over-limit')), findsOneWidget);
    await tester.runAsync(
      () => tester.tap(find.byKey(const Key('discount-apply'))),
    );
    await settle(tester);
  }

  testWidgets(
    "D5: a cashier's 15% discount asks for a manager; without one it is refused",
    (tester) async {
      await pumpSale(tester, sessionOf(cashier, cashierPermissions));
      await giveFifteenPercent(tester);
      expect(approvalsAsked, ['sale.discount_over_limit']);
      expect(find.byKey(const Key('discount-error')), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await settle(tester);
      expect(
        tester.widget<Text>(find.byKey(const Key('ticket-total'))).data,
        r'$22.00',
      );
    },
  );

  testWidgets('D5: with a manager approval the discount carries the approver', (
    tester,
  ) async {
    approval = OfflineApprovalResult(
      id: 'a1',
      approverStaffId: manager.id,
      requesterStaffId: cashier.id,
      action: 'sale.discount_over_limit',
      createdAt: DateTime.utc(2026, 11, 2),
    );
    await pumpSale(tester, sessionOf(cashier, cashierPermissions));
    await giveFifteenPercent(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('ticket-total'))).data,
      r'$18.70',
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SaleScreen)),
    );
    expect(
      container.read(ticketProvider).orderDiscount!.approverStaffId,
      manager.id,
    );
  });

  testWidgets('a manager gives 15% without asking anyone', (tester) async {
    await pumpSale(
      tester,
      sessionOf(manager, [...cashierPermissions, 'sale.discount_over_limit']),
    );
    await giveFifteenPercent(tester);
    expect(approvalsAsked, isEmpty);
    expect(
      tester.widget<Text>(find.byKey(const Key('ticket-total'))).data,
      r'$18.70',
    );
  });

  testWidgets(
    'lowering a quantity records the voided units; clearing the ticket is confirmed and recorded',
    (tester) async {
      await pumpSale(tester, sessionOf(cashier, cashierPermissions));
      await tester.tap(find.text('Concha'));
      await tester.tap(find.text('Concha'));
      await tester.tap(find.text('Galletas'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('ticket-line-1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('line-minus')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('line-quantity'))).data,
        '1',
      );
      await tester.tap(find.byKey(const Key('line-done')));
      await settle(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SaleScreen)),
      );
      final voided = container.read(ticketProvider).voided.single;
      expect(voided.quantity, 1);
      expect(voided.staffId, cashier.id);

      await tester.tap(find.byKey(const Key('ticket-clear')));
      await settle(tester);
      await tester.runAsync(
        () => tester.tap(find.byKey(const Key('ticket-clear-confirm'))),
      );
      await settle(tester);
      expect(find.byKey(const Key('ticket-empty')), findsOneWidget);
      final outbox = await tester.runAsync(
        () => db.select(db.outboxEntries).get(),
      );
      expect(outbox!.single.payload, contains('sale.ticket_discarded'));
      expect(
        await tester.runAsync(() => db.select(db.localSales).get()),
        isEmpty,
      );
    },
  );

  testWidgets('without a folio prefix the till asks to sync before charging', (
    tester,
  ) async {
    await pumpSale(tester, sessionOf(cashier, cashierPermissions));
    await tester.runAsync(
      () => db.customStatement(
        "DELETE FROM session_state_entries WHERE key = 'sale.folioPrefix'",
      ),
    );
    await tester.tap(find.text('Concha'));
    await tester.pump();
    await tester.runAsync(
      () => tester.tap(find.byKey(const Key('ticket-pay'))),
    );
    await settle(tester);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byKey(const Key('payment-total')), findsNothing);
  });
}

/// Lets Drift's real-zone futures finish, then settles the frames.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await tester.pumpAndSettle();
}
