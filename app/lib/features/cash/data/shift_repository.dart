import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/local_database.dart';
import '../domain/cash_totals.dart';
import '../domain/z_report.dart';

/// Key in the till's settings, from the staff bundle.
const cashVarianceFlagKey = 'cash.varianceFlagCents';

/// The last Z number this till used (sync state table).
const zNumberKey = 'cash.zNumber';

/// What a difference is flagged above when the server has not said yet.
const defaultCashVarianceFlagCents = 5000;

/// The till already has a shift that is not closed.
class ShiftAlreadyOpenException implements Exception {
  const ShiftAlreadyOpenException();
}

String formatZLabel(String prefix, int zNumber) =>
    '$prefix-Z${zNumber.toString().padLeft(4, '0')}';

/// Runs the shift on the till. Every step is written with its outbox record
/// in one transaction; the server recomputes the close (M4 brief 4.6).
class ShiftRepository {
  ShiftRepository(this._db, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final Uuid _uuid;

  Future<int> varianceFlagCents() async =>
      int.tryParse(await _db.getSessionValue(cashVarianceFlagKey) ?? '') ??
      defaultCashVarianceFlagCents;

  /// The shift the drawer is on: open, or counted and waiting for its note.
  Selectable<LocalShift> _current() =>
      _db.select(_db.localShifts)..where((s) => s.status.isNotValue('CLOSED'));

  Future<LocalShift?> current() => _current().getSingleOrNull();

  /// Closed shifts, newest first.
  Future<List<LocalShift>> closed({int limit = 30}) =>
      (_db.select(_db.localShifts)
            ..where((s) => s.status.equals('CLOSED'))
            ..orderBy([
              (s) =>
                  OrderingTerm(expression: s.openedAt, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .get();

  Iterable<Insertable<LocalCashCount>> _countRows(
    String shiftId,
    String stage,
    Map<int, int> count,
  ) => [
    for (final e in count.entries)
      LocalCashCountsCompanion.insert(
        shiftId: shiftId,
        stage: stage,
        denominationCents: e.key,
        quantity: e.value,
      ),
  ];

  List<Map<String, int>> _countJson(Map<int, int> count) => [
    for (final e in count.entries)
      {'denominationCents': e.key, 'quantity': e.value},
  ];

  /// Stores the shift, its count and `shift.opened` together (E2).
  Future<String> open({
    required StaffEntry staff,
    required Map<int, int> count,
    required DateTime now,
  }) async {
    final id = _uuid.v7();
    final at = now.toUtc();
    final total = countTotal(count);
    await _db.transaction(() async {
      if (await current() != null) throw const ShiftAlreadyOpenException();
      await _db
          .into(_db.localShifts)
          .insert(
            LocalShiftsCompanion.insert(
              id: id,
              status: 'OPEN',
              openedAt: at,
              openedByStaffId: staff.id,
              openedByName: staff.displayName,
              floatCents: total,
            ),
          );
      await _db.batch(
        (b) => b.insertAll(_db.localCashCounts, _countRows(id, 'OPEN', count)),
      );
      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: id,
              type: 'shift.opened',
              occurredAt: at,
              actorStaffId: Value(staff.id),
              payload: jsonEncode({
                'staffId': staff.id,
                'floatCents': total,
                'count': _countJson(count),
              }),
            ),
          );
    });
    return id;
  }

  /// The last closed shift's count, to warn about a different float.
  Future<int?> lastCountedCents() async {
    final row =
        await (_db.select(_db.localShifts)
              ..where((s) => s.status.equals('CLOSED'))
              ..orderBy([
                (s) => OrderingTerm(
                  expression: s.openedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row?.countedCents;
  }

  Future<void> addMovement({
    required String shiftId,
    required CashKind kind,
    required int amountCents,
    required CashReason reason,
    String? note,
    required String staffId,
    String? approverStaffId,
    required DateTime now,
  }) {
    final id = _uuid.v7();
    final at = now.toUtc();
    return _db.transaction(() async {
      await _db
          .into(_db.localCashMovements)
          .insert(
            LocalCashMovementsCompanion.insert(
              id: id,
              shiftId: shiftId,
              kind: kind.json,
              amountCents: amountCents,
              reason: reason.json,
              note: Value(note),
              staffId: staffId,
              approverStaffId: Value(approverStaffId),
              occurredAt: at,
            ),
          );
      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: id,
              type: 'cash.movement',
              occurredAt: at,
              actorStaffId: Value(staffId),
              payload: jsonEncode({
                'shiftId': shiftId,
                'kind': kind.json,
                'amountCents': amountCents,
                'reason': reason.json,
                'note': note,
                'staffId': staffId,
                'approverStaffId': approverStaffId,
              }),
            ),
          );
    });
  }

  Future<CloseResult> _compute(LocalShift shift, int counted, int flag) async {
    final sales = await (_db.select(
      _db.localSales,
    )..where((s) => s.shiftId.equals(shift.id))).get();
    final refunds = await (_db.select(
      _db.localRefunds,
    )..where((r) => r.shiftId.equals(shift.id))).get();
    final moves = await (_db.select(
      _db.localCashMovements,
    )..where((m) => m.shiftId.equals(shift.id))).get();
    List<int> amounts(CashKind k) => [
      for (final m in moves)
        if (m.kind == k.json) m.amountCents,
    ];
    return closeResult(
      floatCents: shift.floatCents,
      saleAmountsCents: [for (final s in sales) s.totalCents],
      cashInCents: amounts(CashKind.cashIn),
      cashOutCents: amounts(CashKind.cashOut),
      refundsCents: [for (final r in refunds) r.totalCents],
      countedCents: counted,
      flagCents: flag,
    );
  }

  /// The blind count is final from here (M4 brief 4.4): takes the Z number,
  /// stores the count and works out the difference. A flagged difference
  /// waits in `COUNTED` for [finishClose]; anything else closes at once.
  Future<LocalShift> confirmCount({
    required LocalShift shift,
    required StaffEntry staff,
    required Map<int, int> count,
    required DateTime now,
  }) {
    final at = now.toUtc();
    final counted = countTotal(count);
    return _db.transaction(() async {
      final flag = await varianceFlagCents();
      final result = await _compute(shift, counted, flag);
      final row = await (_db.select(
        _db.syncStateEntries,
      )..where((t) => t.key.equals(zNumberKey))).getSingleOrNull();
      final z = (row?.intValue ?? 0) + 1;
      await _db
          .into(_db.syncStateEntries)
          .insertOnConflictUpdate(
            SyncStateEntriesCompanion.insert(key: zNumberKey, intValue: z),
          );
      await _db.batch(
        (b) => b.insertAll(
          _db.localCashCounts,
          _countRows(shift.id, 'CLOSE', count),
        ),
      );
      await (_db.update(
        _db.localShifts,
      )..where((s) => s.id.equals(shift.id))).write(
        LocalShiftsCompanion(
          status: const Value('COUNTED'),
          zNumber: Value(z),
          closedAt: Value(at),
          closedByStaffId: Value(staff.id),
          closedByName: Value(staff.displayName),
          expectedCents: Value(result.expectedCents),
          countedCents: Value(counted),
          varianceCents: Value(result.varianceCents),
          flagged: Value(result.flagged),
        ),
      );
      if (!result.flagged) await _finish(shift.id, null);
      return (_db.select(
        _db.localShifts,
      )..where((s) => s.id.equals(shift.id))).getSingle();
    });
  }

  /// Ends a `COUNTED` shift with the note a flagged difference needs.
  Future<void> finishClose(String shiftId, String note) =>
      _db.transaction(() => _finish(shiftId, note));

  Future<void> _finish(String shiftId, String? note) async {
    final s = await (_db.select(
      _db.localShifts,
    )..where((x) => x.id.equals(shiftId))).getSingle();
    final rows = await (_db.select(
      _db.localCashCounts,
    )..where((c) => c.shiftId.equals(shiftId) & c.stage.equals('CLOSE'))).get();
    await (_db.update(
      _db.localShifts,
    )..where((x) => x.id.equals(shiftId))).write(
      LocalShiftsCompanion(status: const Value('CLOSED'), note: Value(note)),
    );
    await _db
        .into(_db.outboxEntries)
        .insert(
          OutboxEntriesCompanion.insert(
            id: _uuid.v7(),
            type: 'shift.closed',
            occurredAt: s.closedAt!,
            actorStaffId: Value(s.closedByStaffId),
            payload: jsonEncode({
              'shiftId': s.id,
              'zNumber': s.zNumber,
              'staffId': s.closedByStaffId,
              'count': [
                for (final r in rows)
                  {
                    'denominationCents': r.denominationCents,
                    'quantity': r.quantity,
                  },
              ],
              'countedCents': s.countedCents,
              'expectedCents': s.expectedCents,
              'varianceCents': s.varianceCents,
              'flagged': s.flagged,
              'note': note,
            }),
          ),
        );
  }

  /// The Z report of [shiftId], from the rows this till stored.
  Future<ZReport> zReport(String shiftId) async {
    final sales = await (_db.select(
      _db.localSales,
    )..where((s) => s.shiftId.equals(shiftId))).get();
    final ids = [for (final s in sales) s.id];
    final lines = await (_db.select(
      _db.localSaleLines,
    )..where((l) => l.saleId.isIn(ids))).get();
    final refunds = await (_db.select(
      _db.localRefunds,
    )..where((r) => r.shiftId.equals(shiftId))).get();
    final moves = await (_db.select(
      _db.localCashMovements,
    )..where((m) => m.shiftId.equals(shiftId))).get();
    return computeZReport(
      [
        for (final s in sales)
          ZSale(
            grossCents: s.grossCents,
            discountCents: s.discountCents,
            totalCents: s.totalCents,
            lines: [
              for (final l in lines)
                if (l.saleId == s.id)
                  ZLine(
                    ivaBp: l.ivaBp,
                    iepsBp: l.iepsBp,
                    baseCents: l.baseCents,
                    iepsCents: l.iepsCents,
                    ivaCents: l.ivaCents,
                  ),
            ],
          ),
      ],
      [
        for (final r in refunds)
          ZRefund(
            isVoid: r.kind == 'VOID',
            totalCents: r.totalCents,
            lines: _refundLines(r),
          ),
      ],
      [
        for (final m in moves)
          ZMovement(kind: m.kind, reason: m.reason, amountCents: m.amountCents),
      ],
    );
  }

  List<ZLine> _refundLines(LocalRefund r) {
    final rates = {
      for (final x in (jsonDecode(r.ratesJson) as List).cast<Map>())
        x['lineNo'] as int: x,
    };
    return [
      for (final l in (jsonDecode(r.linesJson) as List).cast<Map>())
        ZLine(
          ivaBp: rates[l['lineNo']]?['ivaBp'] as int? ?? 0,
          iepsBp: rates[l['lineNo']]?['iepsBp'] as int? ?? 0,
          baseCents: l['baseCents'] as int,
          iepsCents: l['iepsCents'] as int,
          ivaCents: l['ivaCents'] as int,
        ),
    ];
  }

  /// Counts of a shift by denomination, for the Z report.
  Future<Map<int, int>> counts(String shiftId, String stage) async {
    final rows = await (_db.select(
      _db.localCashCounts,
    )..where((c) => c.shiftId.equals(shiftId) & c.stage.equals(stage))).get();
    return {for (final r in rows) r.denominationCents: r.quantity};
  }
}

final shiftRepositoryProvider = Provider<ShiftRepository>(
  (ref) => ShiftRepository(ref.watch(tillDatabaseProvider)),
);

/// The shift the drawer is on; null when a new one must be opened. Whoever
/// opens or closes a shift invalidates this.
final currentShiftProvider = FutureProvider<LocalShift?>(
  (ref) => ref.watch(shiftRepositoryProvider).current(),
);

/// This till's closed shifts, newest first.
final closedShiftsProvider = FutureProvider<List<LocalShift>>(
  (ref) => ref.watch(shiftRepositoryProvider).closed(),
);
