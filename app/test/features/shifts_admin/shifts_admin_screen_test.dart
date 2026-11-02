import 'package:bakery_pos/core/api/api_client_provider.dart';
import 'package:bakery_pos/core/api/fake/fake_api_interceptor.dart';
import 'package:bakery_pos/core/api/generated/rest_client.dart';
import 'package:bakery_pos/features/shifts_admin/presentation/shifts_admin_screen.dart';
import 'package:bakery_pos/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _balanced = '0192e2b0-5a1e-7000-8000-00000000a001';
const _short = '0192e2b0-5a1e-7000-8000-00000000a002';
const _branch = '0192e2b0-0100-7000-8000-000000000001';
const _device = '0192e2b0-0200-7000-8000-000000000001';
const _staff = '0192e2b0-0300-7000-8000-000000000001';

Map<String, dynamic> shift(String id, int z, int counted, bool flagged) => {
  'id': id,
  'branchId': _branch,
  'deviceId': _device,
  'status': 'CLOSED',
  'zNumber': z,
  'zLabel': 'SUC1-01-Z000$z',
  'openedAt': '2026-11-01T14:00:00.000Z',
  'openedByStaffId': _staff,
  'openedByName': 'Ana',
  'closedAt': '2026-11-01T22:00:00.000Z',
  'closedByStaffId': _staff,
  'closedByName': 'Ana',
  'floatCents': 100000,
  'expectedCents': 150000,
  'countedCents': counted,
  'varianceCents': counted - 150000,
  'flagged': flagged,
  'openCount': [
    {'denominationCents': 50000, 'quantity': 2},
  ],
  'closeCount': [
    {'denominationCents': 50000, 'quantity': 3},
  ],
  'movements': [
    {
      'id': '0192e2b0-5a1e-7000-8000-00000000b001',
      'kind': 'OUT',
      'amountCents': 5000,
      'reason': 'BANK_DROP',
      'note': null,
      'staffId': _staff,
      'approverStaffId': null,
      'occurredAt': '2026-11-01T18:00:00.000Z',
    },
  ],
  'notes': <Object>[],
  'zReport': {
    'saleCount': 12,
    'grossCents': 60000,
    'discountCents': 5000,
    'netCents': 55000,
    'taxes': [
      {'kind': 'IVA', 'rateBp': 0, 'baseCents': 55000, 'taxCents': 0},
    ],
    'refundCount': 0,
    'refundCents': 0,
    'voidCount': 0,
    'voidCents': 0,
    'prepaidCollectedCents': 0,
    'cashInCents': 0,
    'cashOutCents': 5000,
    'movements': [
      {'kind': 'OUT', 'reason': 'BANK_DROP', 'amountCents': 5000},
    ],
  },
};

void main() {
  late FakeApiInterceptor fake;

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          restClientProvider.overrideWithValue(
            RestClient(Dio()..interceptors.add(fake)),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShiftsAdminScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  setUp(() {
    fake = FakeApiInterceptor();
    fake.catalog.shifts.addAll([
      shift(_balanced, 1, 150000, false),
      shift(_short, 2, 140000, true),
    ]);
  });

  testWidgets('E13: lists shifts, flags a difference, filters to differences', (
    t,
  ) async {
    await pump(t);
    expect(find.text('SUC1-01-Z0001'), findsOneWidget);
    expect(find.text('SUC1-01-Z0002'), findsOneWidget);
    expect(find.byKey(const Key('shift-flag-$_short')), findsOneWidget);
    expect(find.text(r'-$100.00'), findsOneWidget);

    await t.tap(find.byKey(const Key('shifts-flagged-filter')));
    await t.pumpAndSettle();
    expect(find.text('SUC1-01-Z0001'), findsNothing);
    expect(find.text('SUC1-01-Z0002'), findsOneWidget);
  });

  testWidgets('E13: opens a Z report and adds a note', (t) async {
    await pump(t);
    await t.tap(find.text('SUC1-01-Z0002'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('shift-detail')), findsOneWidget);
    expect(find.text('Corte Z SUC1-01-Z0002'), findsOneWidget);
    expect(find.text('Depósito al banco'), findsWidgets);

    await t.enterText(find.byKey(const Key('shift-note')), 'Revisado');
    await t.tap(find.byKey(const Key('shift-note-save')));
    await t.pumpAndSettle();
    expect(find.text('Revisado'), findsOneWidget);
  });
}
