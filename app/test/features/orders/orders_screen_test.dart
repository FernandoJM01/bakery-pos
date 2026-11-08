import 'dart:convert';

import 'package:bakery_pos/core/storage/local_database.dart';
import 'package:bakery_pos/core/storage/secure_storage.dart';
import 'package:bakery_pos/features/auth/data/till_auth_service.dart';
import 'package:bakery_pos/features/auth/domain/till_auth_state.dart';
import 'package:bakery_pos/features/orders/data/orders_repository.dart';
import 'package:bakery_pos/features/orders/presentation/orders_screen.dart';
import 'package:bakery_pos/features/sale/domain/ticket.dart';
import 'package:bakery_pos/features/stock/domain/stock_math.dart';
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
  final now = DateTime.now();

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await t.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> pump(WidgetTester t, {required int balance}) async {
    t.view.physicalSize = const Size(1280, 900);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.runAsync(() async {
      await seedTill(db);
      await db
          .into(db.localOrderTickets)
          .insert(
            LocalOrderTicketsCompanion.insert(
              id: 't1',
              orderId: 'o1',
              customerId: 'c1',
              customerName: 'Fonda Doña Mary',
              balanceCents: balance,
              dueDate: localDayOf(now),
              pickupTime: '07:30',
              status: 'PENDING',
              totalCents: 4500,
              linesJson: jsonEncode([
                {
                  'lineNo': 1,
                  'variantId': concha.variantId,
                  'productName': 'Concha',
                  'variantName': 'Pieza',
                  'quantity': 3,
                  'unitPriceCents': 1500,
                  'ivaRateId': iva0,
                  'ivaBp': 0,
                  'iepsBp': 0,
                },
              ]),
            ),
          );
    });
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          tillDatabaseProvider.overrideWithValue(db),
          ordersRepositoryProvider.overrideWith(
            (ref) => OrdersRepository(db, null),
          ),
          tillSessionProvider.overrideWith(
            () => _Session(
              TillSession(
                staff: cashier,
                permissions: const ['sale.create', 'orders.pickup'],
                isOffline: true,
              ),
            ),
          ),
          enrolledBranchNameProvider.overrideWith((_) async => 'Centro'),
          saleClockProvider.overrideWithValue(() => now),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: OrdersScreen()),
        ),
      ),
    );
    await settle(t);
  }

  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('G6: Entregar hands the ticket over in one tap, offline', (
    t,
  ) async {
    await pump(t, balance: 10000);
    expect(find.text('3 × Concha'), findsOneWidget);
    expect(find.text(r'Saldo $100.00'), findsOneWidget);
    await t.runAsync(() => t.tap(find.byKey(const Key('handover-t1'))));
    await settle(t);
    expect(find.byKey(const Key('receipt-prepaid')), findsOneWidget);
    expect(
      t.widget<Text>(find.byKey(const Key('receipt-balance'))).data,
      r'$55.00',
    );
    await t.tap(find.byKey(const Key('receipt-new-sale')));
    await settle(t);
    expect(find.byKey(const Key('handed-t1')), findsOneWidget);
    final rows = await t.runAsync(() => db.select(db.outboxEntries).get());
    expect(rows!.single.type, 'sale.completed');
    await finish(t);
  });

  testWidgets('a balance below the ticket shows saldo bajo', (t) async {
    await pump(t, balance: 1000);
    expect(find.textContaining('Saldo bajo'), findsOneWidget);
    await finish(t);
  });

  testWidgets('G4: Abonar takes cash for the customer', (t) async {
    await pump(t, balance: 0);
    await t.tap(find.byKey(const Key('prepay-t1')));
    await settle(t);
    await t.enterText(find.byKey(const Key('prepay-amount')), '300');
    await t.pump();
    await t.runAsync(() => t.tap(find.byKey(const Key('prepay-save'))));
    await settle(t);
    final rows = await t.runAsync(() => db.select(db.outboxEntries).get());
    final p = jsonDecode(rows!.single.payload) as Map<String, dynamic>;
    expect(rows.single.type, 'order.prepaid');
    expect(p['amountCents'], 30000);
    expect(find.text(r'Saldo $300.00'), findsOneWidget);
    await finish(t);
  });
}
