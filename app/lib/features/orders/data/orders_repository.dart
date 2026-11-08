import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/orders/orders_api_client.dart';
import '../../../core/storage/local_database.dart';
import '../../sale/data/sale_repository.dart';
import '../../sale/domain/ticket.dart';
import '../../stock/domain/stock_math.dart';

/// One order ticket as the counter sees it today, with what this till has
/// not synced yet applied.
class TillTicket {
  const TillTicket({
    required this.row,
    required this.lines,
    required this.pickedUpHere,
    required this.balanceCents,
  });

  final LocalOrderTicket row;
  final List<Map<String, dynamic>> lines;

  /// Handed over on this till, waiting to sync.
  final bool pickedUpHere;

  /// The customer's balance with this till's unsynced records applied.
  final int balanceCents;

  bool get pending => row.status == 'PENDING' && !pickedUpHere;
}

/// Order tickets on the till (M6 brief 4.4): pulled from the server, handed
/// over offline as a sale paid from the balance, and prepayments taken.
class OrdersRepository {
  OrdersRepository(this._db, this._api, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final OrdersApiClient? _api;
  final Uuid _uuid;

  Future<void> pull() async {
    final api = _api;
    if (api == null) return;
    final res = await api.listBranchTickets();
    await _db.transaction(() async {
      await _db.delete(_db.localOrderTickets).go();
      await _db.batch((b) {
        b.insertAll(_db.localOrderTickets, [
          for (final t in res.items)
            LocalOrderTicketsCompanion.insert(
              id: t.id,
              orderId: t.orderId,
              customerId: t.customerId,
              customerName: t.customerName,
              customerPhone: Value(t.customerPhone),
              balanceCents: t.balanceCents,
              dueDate: t.dueDate,
              pickupTime: t.pickupTime,
              status: t.status.json ?? t.status.name,
              totalCents: t.totalCents,
              linesJson: jsonEncode([for (final l in t.lines) l.toJson()]),
            ),
        ]);
      });
    });
  }

  /// What this till has done since the last pull, from its outbox.
  Future<({Set<String> picked, Map<String, int> moved})> _unsynced() async {
    final picked = <String>{};
    final moved = <String, int>{};
    final tickets = {
      for (final t in await _db.select(_db.localOrderTickets).get()) t.id: t,
    };
    for (final r in await _db.pendingOutbox(limit: 100000)) {
      final p = jsonDecode(r.payload) as Map<String, dynamic>;
      if (r.type == 'order.prepaid') {
        final c = p['customerId'] as String;
        moved[c] = (moved[c] ?? 0) + (p['amountCents'] as int);
      } else if (r.type == 'sale.completed' && p['orderTicketId'] != null) {
        final t = tickets[p['orderTicketId']];
        picked.add(p['orderTicketId'] as String);
        if (t != null) {
          moved[t.customerId] =
              (moved[t.customerId] ?? 0) - (p['totalCents'] as int);
        }
      }
    }
    return (picked: picked, moved: moved);
  }

  /// Tickets due on or before today, not picked up on the server, by time.
  Future<List<TillTicket>> today(DateTime now) async {
    final day = localDayOf(now);
    final rows =
        await (_db.select(_db.localOrderTickets)
              ..where(
                (t) =>
                    t.dueDate.isSmallerOrEqualValue(day) &
                    t.status.isIn(const ['PENDING', 'PICKED_UP']),
              )
              ..orderBy([
                (t) => OrderingTerm(expression: t.pickupTime),
                (t) => OrderingTerm(expression: t.customerName),
              ]))
            .get();
    final u = await _unsynced();
    return [
      for (final r in rows)
        TillTicket(
          row: r,
          lines: (jsonDecode(r.linesJson) as List).cast<Map<String, dynamic>>(),
          pickedUpHere: u.picked.contains(r.id),
          balanceCents: r.balanceCents + (u.moved[r.customerId] ?? 0),
        ),
    ];
  }

  /// Totals per product for today's orders, for the baker (M7.4).
  Future<Map<String, ({String name, int quantity})>> todayTotals(
    DateTime now,
  ) async {
    final out = <String, ({String name, int quantity})>{};
    final day = localDayOf(now);
    final rows = await (_db.select(
      _db.localOrderTickets,
    )..where((t) => t.dueDate.equals(day))).get();
    for (final r in rows) {
      for (final l
          in (jsonDecode(r.linesJson) as List).cast<Map<String, dynamic>>()) {
        final id = l['variantId'] as String;
        final name = '${l['productName']} · ${l['variantName']}';
        out[id] = (
          name: name,
          quantity: (out[id]?.quantity ?? 0) + (l['quantity'] as int),
        );
      }
    }
    return out;
  }

  /// The ticket's lines as the sale ticket hands them over: same prices,
  /// same order (the server checks them against the ticket, G7).
  Ticket ticketOf(TillTicket t) => Ticket(
    lines: [
      for (final l in t.lines)
        TicketLine(
          item: SaleItem(
            variantId: l['variantId'] as String,
            productName: l['productName'] as String,
            variantName: l['variantName'] as String,
            unitPriceCents: l['unitPriceCents'] as int,
            ivaRateId: l['ivaRateId'] as String,
            ivaBp: l['ivaBp'] as int,
            iepsRateId: l['iepsRateId'] as String?,
            iepsBp: l['iepsBp'] as int? ?? 0,
          ),
          quantity: l['quantity'] as int,
        ),
    ],
  );

  /// Entregar: a sale paid from the balance, in one tap (M6 brief 4.4).
  Future<SaleReceipt> pickUp({
    required TillTicket ticket,
    required StaffEntry cashier,
    required DateTime now,
  }) => SaleRepository(_db).completeSale(
    ticket: ticketOf(ticket),
    cashier: cashier,
    tenderedCents: 0,
    now: now,
    orderTicketId: ticket.row.id,
  );

  /// Cash toward a customer's orders, in the open shift (M6 brief 4.3).
  Future<void> prepay({
    required String customerId,
    required String customerName,
    required int amountCents,
    required String staffId,
    required DateTime now,
  }) {
    final id = _uuid.v7();
    final at = now.toUtc();
    return _db.transaction(() async {
      final shiftId = await _db.openShiftId();
      if (shiftId == null) throw const NoOpenShiftException();
      await _db
          .into(_db.localPrepayments)
          .insert(
            LocalPrepaymentsCompanion.insert(
              id: id,
              customerId: customerId,
              customerName: customerName,
              shiftId: shiftId,
              amountCents: amountCents,
              occurredAt: at,
            ),
          );
      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              id: id,
              type: 'order.prepaid',
              occurredAt: at,
              actorStaffId: Value(staffId),
              payload: jsonEncode({
                'customerId': customerId,
                'shiftId': shiftId,
                'amountCents': amountCents,
                'staffId': staffId,
              }),
            ),
          );
    });
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(
    ref.watch(tillDatabaseProvider),
    ref.watch(restClientProvider).orders,
  ),
);

/// Today's order tickets; whoever hands one over or takes a payment
/// invalidates this.
final todayTicketsProvider = FutureProvider<List<TillTicket>>(
  (ref) => ref.watch(ordersRepositoryProvider).today(DateTime.now()),
);

/// Today's totals per product from the order tickets, for the baker.
final orderTotalsProvider =
    FutureProvider<Map<String, ({String name, int quantity})>>(
      (ref) => ref.watch(ordersRepositoryProvider).todayTotals(DateTime.now()),
    );
