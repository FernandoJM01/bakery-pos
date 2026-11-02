import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/sale.dart';
import '../../../core/api/generated/rest_client.dart';
import '../../../core/money/tax_split.dart';
import '../../../core/storage/local_database.dart';
import '../domain/sale_totals.dart';
import 'sale_repository.dart' show NoOpenShiftException;

enum RefundKind {
  refund('REFUND'),
  voidSale('VOID');

  const RefundKind(this.json);
  final String json;

  /// The permission a person needs to do it themselves (M1 matrix).
  String get permission =>
      this == RefundKind.voidSale ? 'sale.void_after_payment' : 'sale.refund';
}

enum RefundReason {
  customerReturn('CUSTOMER_RETURN'),
  wrongItem('WRONG_ITEM'),
  quality('QUALITY'),
  cashierError('CASHIER_ERROR'),
  other('OTHER');

  const RefundReason(this.json);
  final String json;
}

class RefundableLine {
  const RefundableLine({
    required this.lineNo,
    required this.name,
    required this.quantity,
    required this.refundedQuantity,
    required this.netCents,
    required this.ivaBp,
    required this.iepsBp,
  });

  final int lineNo;
  final String name;
  final int quantity;
  final int refundedQuantity;
  final int netCents;
  final int ivaBp;
  final int iepsBp;

  int get left => quantity - refundedQuantity;

  /// What [units] more cost back (brief 4.3).
  int amountFor(int units) =>
      refundAmountCents(netCents, quantity, refundedQuantity, units);
}

/// A sale found by folio, as a refund needs it.
class RefundableSale {
  const RefundableSale({
    required this.id,
    required this.folio,
    required this.occurredAt,
    required this.status,
    required this.lines,
    required this.madeHere,
  });

  final String id;
  final String folio;
  final DateTime occurredAt;
  final String status;
  final List<RefundableLine> lines;

  /// The sale was made on this till (it is in the local database).
  final bool madeHere;

  bool get fullyReturned =>
      status == 'REFUNDED' ||
      status == 'VOIDED' ||
      lines.every((l) => l.left == 0);
}

sealed class RefundProblem implements Exception {
  const RefundProblem();
}

/// No sale of this branch has that folio (or, offline, of this till).
class SaleNotFound extends RefundProblem {
  const SaleNotFound();
}

/// More units asked than are left on a line.
class TooManyUnits extends RefundProblem {
  const TooManyUnits(this.lineNo, this.left);
  final int lineNo;
  final int left;
}

/// A cancel must be on this till, on the day of the sale, for every unit.
class VoidNotAllowed extends RefundProblem {
  const VoidNotAllowed(this.reason);
  final VoidRule reason;
}

enum VoidRule { otherTill, otherDay, alreadyReturned, notAllUnits }

class NothingToRefund extends RefundProblem {
  const NothingToRefund();
}

class RefundResult {
  const RefundResult({required this.refundId, required this.totalCents});
  final String refundId;
  final int totalCents;
}

/// Finds sales by folio and records refunds and voids on the till. The
/// server learns of them from the `sale.refunded` outbox record and checks
/// every rule again.
class RefundRepository {
  RefundRepository(this._db, this._api, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final RestClient? _api;
  final Uuid _uuid;

  Future<RefundableSale?> _local(String folio) async {
    final sale = await (_db.select(
      _db.localSales,
    )..where((s) => s.folio.equals(folio))).getSingleOrNull();
    if (sale == null) return null;
    final lines =
        await (_db.select(_db.localSaleLines)
              ..where((l) => l.saleId.equals(sale.id))
              ..orderBy([(l) => OrderingTerm(expression: l.lineNo)]))
            .get();
    return RefundableSale(
      id: sale.id,
      folio: sale.folio,
      occurredAt: sale.occurredAt,
      status: sale.status,
      madeHere: true,
      lines: [
        for (final l in lines)
          RefundableLine(
            lineNo: l.lineNo,
            name: '${l.productName} · ${l.variantName}',
            quantity: l.quantity,
            refundedQuantity: l.refundedQuantity,
            netCents: l.netCents,
            ivaBp: l.ivaBp,
            iepsBp: l.iepsBp,
          ),
      ],
    );
  }

  RefundableSale _fromServer(Sale s) => RefundableSale(
    id: s.id,
    folio: s.folio,
    occurredAt: s.occurredAt,
    status: s.status.json ?? s.status.name,
    madeHere: false,
    lines: [
      for (final l in s.lines)
        RefundableLine(
          lineNo: l.lineNo,
          name: '${l.productName} · ${l.variantName}',
          quantity: l.quantity,
          refundedQuantity: l.refundedQuantity,
          netCents: l.netCents,
          ivaBp: l.ivaBp,
          iepsBp: l.iepsBp,
        ),
    ],
  );

  /// Online, the server finds any sale of the branch; offline, only sales
  /// made on this till can be found (brief 4.3). A sale made here is read
  /// locally, where refunds from this till show before they sync; the server
  /// adds any made on another till of the branch.
  Future<RefundableSale> find(String folio, {required bool online}) async {
    final f = folio.trim().toUpperCase();
    final local = await _local(f);
    if (online && _api != null) {
      try {
        final server = await _api.sales.lookupSale(folio: f);
        if (local == null) return _fromServer(server);
        await _catchUp(local, server);
        return (await _local(f))!;
      } catch (_) {
        // Not found, or the connection dropped: same answer offline.
      }
    }
    if (local != null) return local;
    throw const SaleNotFound();
  }

  /// Brings this till's copy of a sale level with refunds the server has
  /// seen from other tills, so what is left and its amounts stay exact.
  Future<void> _catchUp(RefundableSale local, Sale server) async {
    final behind = [
      for (final l in server.lines)
        if (local.lines.any(
          (x) =>
              x.lineNo == l.lineNo && x.refundedQuantity < l.refundedQuantity,
        ))
          l,
    ];
    if (behind.isEmpty) return;
    await _db.transaction(() async {
      for (final l in behind) {
        await (_db.update(_db.localSaleLines)..where(
              (x) => x.saleId.equals(local.id) & x.lineNo.equals(l.lineNo),
            ))
            .write(
              LocalSaleLinesCompanion(
                refundedQuantity: Value(l.refundedQuantity),
                refundedCents: Value(l.refundedCents ?? 0),
              ),
            );
      }
      final lines = await (_db.select(
        _db.localSaleLines,
      )..where((x) => x.saleId.equals(local.id))).get();
      await (_db.update(
        _db.localSales,
      )..where((s) => s.id.equals(local.id))).write(
        LocalSalesCompanion(
          status: Value(
            lines.every((l) => l.refundedQuantity == l.quantity)
                ? 'REFUNDED'
                : 'PARTIALLY_REFUNDED',
          ),
          refundedCents: Value(lines.fold(0, (a, l) => a + l.refundedCents)),
        ),
      );
    });
  }

  /// Records a refund (or a void) of [units] per line number, with its
  /// outbox record, in one transaction.
  Future<RefundResult> record({
    required RefundableSale sale,
    required Map<int, int> units,
    required Set<int> restock,
    required RefundKind kind,
    required RefundReason reason,
    String? note,
    required String staffId,
    String? approverStaffId,
    required DateTime now,
  }) async {
    final asked = {
      for (final e in units.entries)
        if (e.value > 0) e.key: e.value,
    };
    if (asked.isEmpty) throw const NothingToRefund();
    if (kind == RefundKind.voidSale) {
      if (!sale.madeHere) throw const VoidNotAllowed(VoidRule.otherTill);
      final day = sale.occurredAt.toLocal();
      final today = now.toLocal();
      if (day.year != today.year ||
          day.month != today.month ||
          day.day != today.day) {
        throw const VoidNotAllowed(VoidRule.otherDay);
      }
      if (sale.fullyReturned) {
        throw const VoidNotAllowed(VoidRule.alreadyReturned);
      }
    }

    final refundId = _uuid.v7();
    return _db.transaction(() async {
      final shiftId = await _db.openShiftId();
      if (shiftId == null) throw const NoOpenShiftException();
      // Read the lines again inside the transaction for a sale made here,
      // so two refunds cannot take the same unit.
      final current = sale.madeHere ? (await _local(sale.folio)) ?? sale : sale;
      if (kind == RefundKind.voidSale &&
          current.lines.any((l) => (asked[l.lineNo] ?? 0) != l.left)) {
        throw const VoidNotAllowed(VoidRule.notAllUnits);
      }
      final lines = <Map<String, Object>>[];
      final rates = <Map<String, int>>[];
      var total = 0;
      for (final l in current.lines) {
        final k = asked[l.lineNo] ?? 0;
        if (k == 0) continue;
        if (k > l.left) throw TooManyUnits(l.lineNo, l.left);
        final amount = l.amountFor(k);
        final t = splitTax(amount, l.ivaBp, l.iepsBp);
        total += amount;
        lines.add({
          'lineNo': l.lineNo,
          'quantity': k,
          'amountCents': amount,
          'baseCents': t.baseCents,
          'iepsCents': t.iepsCents,
          'ivaCents': t.ivaCents,
          'restock': restock.contains(l.lineNo),
        });
        rates.add({'lineNo': l.lineNo, 'ivaBp': l.ivaBp, 'iepsBp': l.iepsBp});
      }
      if (asked.keys.any((n) => current.lines.every((l) => l.lineNo != n))) {
        throw const NothingToRefund();
      }

      final at = now.toUtc();
      await _db
          .into(_db.localRefunds)
          .insert(
            LocalRefundsCompanion.insert(
              id: refundId,
              saleId: sale.id,
              folio: sale.folio,
              shiftId: Value(shiftId),
              kind: kind.json,
              reason: reason.json,
              note: Value(note),
              staffId: staffId,
              approverStaffId: Value(approverStaffId),
              occurredAt: at,
              totalCents: total,
              linesJson: jsonEncode(lines),
              ratesJson: Value(jsonEncode(rates)),
            ),
          );

      if (sale.madeHere) {
        for (final l in lines) {
          final no = l['lineNo']! as int;
          await (_db.update(_db.localSaleLines)
                ..where((x) => x.saleId.equals(sale.id) & x.lineNo.equals(no)))
              .write(
                LocalSaleLinesCompanion.custom(
                  refundedQuantity:
                      _db.localSaleLines.refundedQuantity +
                      Variable(l['quantity']! as int),
                  refundedCents:
                      _db.localSaleLines.refundedCents +
                      Variable(l['amountCents']! as int),
                ),
              );
        }
        final allGone = current.lines.every(
          (l) => l.left == (asked[l.lineNo] ?? 0),
        );
        await (_db.update(
          _db.localSales,
        )..where((s) => s.id.equals(sale.id))).write(
          LocalSalesCompanion.custom(
            status: Constant(
              kind == RefundKind.voidSale
                  ? 'VOIDED'
                  : allGone
                  ? 'REFUNDED'
                  : 'PARTIALLY_REFUNDED',
            ),
            refundedCents: _db.localSales.refundedCents + Variable(total),
          ),
        );
      }

      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: refundId,
              type: 'sale.refunded',
              occurredAt: at,
              actorStaffId: Value(staffId),
              payload: jsonEncode({
                'saleId': sale.id,
                'shiftId': shiftId,
                'kind': kind.json,
                'reason': reason.json,
                'note': note,
                'staffId': staffId,
                'approverStaffId': approverStaffId,
                'lines': lines,
                'totalCents': total,
              }),
            ),
          );
      return RefundResult(refundId: refundId, totalCents: total);
    });
  }
}

final refundRepositoryProvider = Provider<RefundRepository>(
  (ref) => RefundRepository(
    ref.watch(tillDatabaseProvider),
    ref.watch(restClientProvider),
  ),
);
