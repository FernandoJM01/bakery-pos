import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/local_database.dart';
import '../domain/sale_totals.dart';
import '../domain/ticket.dart';

/// Keys in the till's settings (session state table), from the staff bundle.
const folioPrefixKey = 'sale.folioPrefix';
const discountLimitKey = 'sale.discountLimitBp';

/// The last folio number this till used (sync state table).
const folioNumberKey = 'sale.folioNumber';

/// What the cashier limit is when the server has not sent one yet.
const defaultDiscountLimitBp = 1000;

/// The till has no folio prefix yet: it must sync its staff bundle once.
class NoFolioPrefixException implements Exception {
  const NoFolioPrefixException();
}

/// The cash given does not cover the total.
class InsufficientCashException implements Exception {
  const InsufficientCashException();
}

/// Everything the receipt shows (M3 brief 4.1).
class SaleReceipt {
  const SaleReceipt({
    required this.saleId,
    required this.folio,
    required this.occurredAt,
    required this.cashierName,
    required this.ticket,
    required this.totals,
    required this.tenderedCents,
    required this.changeCents,
  });

  final String saleId;
  final String folio;
  final DateTime occurredAt;
  final String cashierName;
  final Ticket ticket;
  final SaleTotals totals;
  final int tenderedCents;
  final int changeCents;
}

String formatFolio(String prefix, int number) =>
    '$prefix-${number.toString().padLeft(6, '0')}';

/// Writes sales on the till. A sale exists once [completeSale] returns; the
/// server learns of it from the `sale.completed` outbox record.
class SaleRepository {
  SaleRepository(this._db, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final Uuid _uuid;

  Future<String?> folioPrefix() => _db.getSessionValue(folioPrefixKey);

  Future<int> discountLimitBp() async =>
      int.tryParse(await _db.getSessionValue(discountLimitKey) ?? '') ??
      defaultDiscountLimitBp;

  Future<int> lastFolioNumber() async {
    final row = await (_db.select(
      _db.syncStateEntries,
    )..where((t) => t.key.equals(folioNumberKey))).getSingleOrNull();
    return row?.intValue ?? 0;
  }

  /// Stores the sale paid with [tenderedCents] cash, in one transaction
  /// (D2): the next folio number, the sale with its lines and discounts,
  /// and one `sale.completed` outbox record. If any part fails, none of
  /// them is kept and the folio number is not used.
  Future<SaleReceipt> completeSale({
    required Ticket ticket,
    required StaffEntry cashier,
    required int tenderedCents,
    required DateTime now,
  }) async {
    if (ticket.isEmpty) throw StateError('Empty ticket');
    final prefix = await folioPrefix();
    if (prefix == null || prefix.isEmpty) throw const NoFolioPrefixException();
    final totals = ticket.totals;
    if (tenderedCents < totals.totalCents) {
      throw const InsufficientCashException();
    }
    final change = tenderedCents - totals.totalCents;
    final saleId = _uuid.v7();
    final at = now.toUtc();

    return _db.transaction(() async {
      final number = await lastFolioNumber() + 1;
      final folio = formatFolio(prefix, number);

      await _db
          .into(_db.localSales)
          .insert(
            LocalSalesCompanion.insert(
              id: saleId,
              folio: folio,
              folioNumber: number,
              cashierStaffId: cashier.id,
              cashierName: cashier.displayName,
              occurredAt: at,
              grossCents: totals.grossCents,
              discountCents: totals.discountCents,
              totalCents: totals.totalCents,
              tenderedCents: tenderedCents,
              changeCents: change,
              voidedLinesJson: Value(
                jsonEncode([for (final v in ticket.voided) v.toJson()]),
              ),
            ),
          );

      final lines = <Map<String, Object?>>[];
      await _db.batch((b) {
        for (final (i, l) in ticket.lines.indexed) {
          final t = totals.lines[i];
          b.insert(
            _db.localSaleLines,
            LocalSaleLinesCompanion.insert(
              saleId: saleId,
              lineNo: t.lineNo,
              variantId: l.item.variantId,
              productName: l.item.productName,
              variantName: l.item.variantName,
              quantity: l.quantity,
              unitPriceCents: l.item.unitPriceCents,
              grossCents: t.grossCents,
              lineDiscountCents: t.lineDiscountCents,
              orderDiscountCents: t.orderDiscountCents,
              netCents: t.netCents,
              ivaRateId: l.item.ivaRateId,
              ivaBp: l.item.ivaBp,
              iepsRateId: Value(l.item.iepsRateId),
              iepsBp: l.item.iepsBp,
              baseCents: t.tax.baseCents,
              iepsCents: t.tax.iepsCents,
              ivaCents: t.tax.ivaCents,
            ),
          );
          if (l.discount != null) {
            b.insert(
              _db.localSaleDiscounts,
              _discountRow(saleId, t.lineNo, l.discount!, t.lineDiscountCents),
            );
          }
          lines.add({
            'lineNo': t.lineNo,
            'variantId': l.item.variantId,
            'productName': l.item.productName,
            'variantName': l.item.variantName,
            'quantity': l.quantity,
            'unitPriceCents': l.item.unitPriceCents,
            'ivaRateId': l.item.ivaRateId,
            'ivaBp': l.item.ivaBp,
            'iepsRateId': l.item.iepsRateId,
            'iepsBp': l.item.iepsBp,
            'discount': l.discount?.toJson(),
            ...t.toJson(),
          });
        }
        if (ticket.orderDiscount != null) {
          b.insert(
            _db.localSaleDiscounts,
            _discountRow(
              saleId,
              null,
              ticket.orderDiscount!,
              totals.orderDiscountCents,
            ),
          );
        }
      });

      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: saleId,
              type: 'sale.completed',
              occurredAt: at,
              actorStaffId: Value(cashier.id),
              payload: jsonEncode({
                'folio': folio,
                'folioNumber': number,
                'cashierStaffId': cashier.id,
                'shiftId': null,
                'lines': lines,
                'orderDiscount': ticket.orderDiscount?.toJson(),
                'voidedLines': [for (final v in ticket.voided) v.toJson()],
                'grossCents': totals.grossCents,
                'discountCents': totals.discountCents,
                'totalCents': totals.totalCents,
                'payments': [
                  {
                    'method': 'CASH',
                    'amountCents': totals.totalCents,
                    'tenderedCents': tenderedCents,
                    'changeCents': change,
                  },
                ],
              }),
            ),
          );

      await _db
          .into(_db.syncStateEntries)
          .insertOnConflictUpdate(
            SyncStateEntriesCompanion.insert(
              key: folioNumberKey,
              intValue: number,
            ),
          );

      return SaleReceipt(
        saleId: saleId,
        folio: folio,
        occurredAt: at,
        cashierName: cashier.displayName,
        ticket: ticket,
        totals: totals,
        tenderedCents: tenderedCents,
        changeCents: change,
      );
    });
  }

  LocalSaleDiscountsCompanion _discountRow(
    String saleId,
    int? lineNo,
    TicketDiscount d,
    int cents,
  ) => LocalSaleDiscountsCompanion.insert(
    id: _uuid.v7(),
    saleId: saleId,
    lineNo: Value(lineNo),
    kind: d.kind.json,
    value: d.value,
    cents: cents,
    reason: d.reason.json,
    note: Value(d.note),
    approverStaffId: Value(d.approverStaffId),
  );

  /// A ticket with lines left without paying (`sale.ticket_discarded`).
  Future<void> discardTicket(
    Ticket ticket,
    String staffId,
    DateTime now,
  ) async {
    if (ticket.isEmpty) return;
    await _db.recordTicketDiscarded(
      staffId: staffId,
      lineCount: ticket.lines.length,
      amountCents: ticket.totals.totalCents,
      at: now.toUtc(),
    );
  }
}

final saleRepositoryProvider = Provider<SaleRepository>(
  (ref) => SaleRepository(ref.watch(tillDatabaseProvider)),
);

/// The cashier discount limit in basis points, from the staff bundle.
final discountLimitProvider = FutureProvider<int>(
  (ref) => ref.watch(saleRepositoryProvider).discountLimitBp(),
);
