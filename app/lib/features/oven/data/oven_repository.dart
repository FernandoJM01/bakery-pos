import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/oven/oven_api_client.dart';
import '../../../core/storage/local_database.dart';
import '../../sale/data/sale_repository.dart';
import '../../sale/domain/ticket.dart';
import '../domain/oven_fee.dart';

const ovenEnabledKey = 'oven.enabled';

/// A dish as this till sees it, with its unsynced steps applied.
class OvenDish {
  OvenDish({
    required this.id,
    required this.tag,
    required this.customerName,
    required this.phone,
    required this.description,
    required this.ruleId,
    required this.weightGrams,
    required this.feeCents,
    required this.requestedAt,
    required this.status,
    required this.readyAt,
    required this.paid,
  });

  final String id;
  final String tag;
  final String customerName;
  final String? phone;
  final String description;
  final String ruleId;
  final int weightGrams;
  final int feeCents;
  final DateTime requestedAt;
  String status;
  DateTime? readyAt;
  bool paid;
}

/// The oven service on the till and the oven board (M8). Works offline from
/// the last pull; every step is an outbox record.
class OvenRepository {
  OvenRepository(this._db, this._api, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final OvenApiClient? _api;
  final Uuid _uuid;

  Future<void> pull() async {
    final api = _api;
    if (api == null) return;
    final b = await api.getOvenBoard();
    await _db.transaction(() async {
      await _db.setSessionValue(ovenEnabledKey, '${b.enabled}');
      await _db.delete(_db.localOvenRules).go();
      await _db.delete(_db.localOvenTickets).go();
      await _db.batch((x) {
        x.insertAll(_db.localOvenRules, [
          for (final r in b.rules)
            LocalOvenRulesCompanion.insert(
              id: r.id,
              name: r.name,
              baseCents: r.baseCents,
              perKgCents: r.perKgCents,
              variantId: r.variantId,
              productName: r.productName,
              ivaRateId: r.ivaRateId,
              ivaBp: r.ivaBp,
              iepsRateId: Value(r.iepsRateId),
              iepsBp: r.iepsBp,
            ),
        ]);
        x.insertAll(_db.localOvenTickets, [
          for (final t in b.tickets)
            LocalOvenTicketsCompanion.insert(
              id: t.id,
              tag: t.tag,
              customerName: t.customerName,
              phone: Value(t.phone),
              description: t.description,
              ruleId: t.ruleId,
              weightGrams: t.weightGrams,
              feeCents: t.feeCents,
              requestedAt: t.requestedAt,
              status: t.status.json ?? t.status.name,
              readyAt: Value(t.readyAt),
              paid: t.paid,
            ),
        ]);
      });
    });
  }

  Future<bool> enabled() async =>
      await _db.getSessionValue(ovenEnabledKey) == 'true';

  Future<List<LocalOvenRule>> rules() => (_db.select(
    _db.localOvenRules,
  )..orderBy([(r) => OrderingTerm(expression: r.name)])).get();

  /// Dishes not picked up, plus today's pickups, by requested time.
  Future<List<OvenDish>> dishes() async {
    final out = <String, OvenDish>{};
    for (final t in await _db.select(_db.localOvenTickets).get()) {
      out[t.id] = OvenDish(
        id: t.id,
        tag: t.tag,
        customerName: t.customerName,
        phone: t.phone,
        description: t.description,
        ruleId: t.ruleId,
        weightGrams: t.weightGrams,
        feeCents: t.feeCents,
        requestedAt: t.requestedAt,
        status: t.status,
        readyAt: t.readyAt,
        paid: t.paid,
      );
    }
    void step(OvenDish d, String status, DateTime at) {
      if (ovenStep(status) <= ovenStep(d.status)) return;
      d.status = status;
      if (status == 'READY' || status == 'PICKED_UP') d.readyAt ??= at;
    }

    for (final r in await _db.pendingOutbox(limit: 100000)) {
      final p = jsonDecode(r.payload) as Map<String, dynamic>;
      switch (r.type) {
        case 'oven.received':
          out[r.id] = OvenDish(
            id: r.id,
            tag: p['tag'] as String,
            customerName: p['customerName'] as String,
            phone: p['phone'] as String?,
            description: p['description'] as String,
            ruleId: p['ruleId'] as String,
            weightGrams: p['weightGrams'] as int,
            feeCents: p['feeCents'] as int,
            requestedAt: DateTime.parse(p['requestedAt'] as String),
            status: 'RECEIVED',
            readyAt: null,
            paid: p['feeSaleId'] != null,
          );
        case 'oven.status':
          final d = out[p['ticketId']];
          if (d != null) step(d, p['status'] as String, r.occurredAt);
        case 'oven.picked_up':
          final d = out[p['ticketId']];
          if (d != null) {
            step(d, 'PICKED_UP', r.occurredAt);
            if (p['feeSaleId'] != null) d.paid = true;
          }
      }
    }
    return out.values.toList()
      ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  /// The fee as a sale of the rule's service product, cash in the shift.
  Future<SaleReceipt> payFee({
    required LocalOvenRule rule,
    required int feeCents,
    required StaffEntry cashier,
    required int tenderedCents,
    required DateTime now,
  }) => SaleRepository(_db).completeSale(
    ticket: Ticket(
      lines: [
        TicketLine(
          item: SaleItem(
            variantId: rule.variantId,
            productName: rule.productName,
            variantName: rule.name,
            unitPriceCents: feeCents,
            ivaRateId: rule.ivaRateId,
            ivaBp: rule.ivaBp,
            iepsRateId: rule.iepsRateId,
            iepsBp: rule.iepsBp,
          ),
          quantity: 1,
        ),
      ],
    ),
    cashier: cashier,
    tenderedCents: tenderedCents,
    now: now,
  );

  Future<String> _record(
    String type,
    DateTime now,
    String staffId,
    Map<String, Object?> payload, [
    String? id,
  ]) async {
    final rid = id ?? _uuid.v7();
    await _db
        .into(_db.outboxEntries)
        .insert(
          OutboxEntriesCompanion.insert(
            id: rid,
            type: type,
            occurredAt: now.toUtc(),
            actorStaffId: Value(staffId),
            payload: jsonEncode(payload),
          ),
        );
    return rid;
  }

  /// Drop-off (M8.1). Returns the dish id.
  Future<String> receive({
    required String tag,
    required String customerName,
    String? phone,
    required String description,
    required LocalOvenRule rule,
    required int weightGrams,
    required DateTime requestedAt,
    required String staffId,
    String? feeSaleId,
    required DateTime now,
  }) => _record('oven.received', now, staffId, {
    'tag': tag.trim(),
    'customerName': customerName.trim(),
    'phone': phone == null ? null : cleanOvenPhone(phone),
    'description': description.trim(),
    'ruleId': rule.id,
    'weightGrams': weightGrams,
    'feeCents': ovenFee(rule.baseCents, rule.perKgCents, weightGrams),
    'requestedAt': requestedAt.toUtc().toIso8601String(),
    'staffId': staffId,
    'feeSaleId': feeSaleId,
  });

  Future<void> mark(
    String dishId,
    String status,
    String staffId,
    DateTime now,
  ) => _record('oven.status', now, staffId, {
    'ticketId': dishId,
    'status': status,
    'staffId': staffId,
  });

  Future<void> pickUp(
    String dishId,
    String staffId,
    DateTime now, {
    String? feeSaleId,
  }) => _record('oven.picked_up', now, staffId, {
    'ticketId': dishId,
    'staffId': staffId,
    'feeSaleId': feeSaleId,
  });
}

final ovenRepositoryProvider = Provider<OvenRepository>(
  (ref) => OvenRepository(
    ref.watch(tillDatabaseProvider),
    ref.watch(restClientProvider).oven,
  ),
);

/// Whoever changes a dish invalidates this.
final ovenDishesProvider = FutureProvider<List<OvenDish>>(
  (ref) => ref.watch(ovenRepositoryProvider).dishes(),
);
