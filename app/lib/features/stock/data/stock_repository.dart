import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/stock/stock_api_client.dart';
import '../../../core/storage/local_database.dart';
import '../domain/stock_math.dart';

/// A lot as the till sees it, with what is waiting in its outbox applied.
class ViewLot {
  ViewLot({
    required this.id,
    required this.variantId,
    required this.producedOn,
    required this.left,
  });

  final String id;
  final String variantId;
  final String producedOn;
  int left;
}

/// One variant's stock today on this till.
class VariantStock {
  const VariantStock({
    required this.fresh,
    required this.dayOld,
    required this.wasteDue,
    required this.short,
    required this.lots,
  });

  final int fresh;
  final int dayOld;
  final int wasteDue;

  /// Units sold with no lot to take from.
  final int short;
  final List<ViewLot> lots;

  int get onHand => fresh + dayOld - short;
}

class WasteDue {
  const WasteDue({
    required this.lot,
    required this.productName,
    required this.variantName,
  });

  final ViewLot lot;
  final String productName;
  final String variantName;
}

/// Stock on the till: the server's lots plus what this till has not synced.
/// The server assigns lots for real (M5 brief 2); this is the till's best
/// view for its buttons and warnings, and it works offline.
class StockRepository {
  StockRepository(this._db, this._api, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final StockApiClient? _api;
  final Uuid _uuid;

  /// Replaces the lots with the server's.
  Future<void> pull() async {
    final api = _api;
    if (api == null) return;
    final stock = await api.listBranchLots();
    await _db.transaction(() async {
      await _db.delete(_db.localLots).go();
      await _db.batch((b) {
        b.insertAll(_db.localLots, [
          for (final l in stock.lots)
            LocalLotsCompanion.insert(
              id: l.id,
              variantId: l.variantId,
              producedOn: l.producedOn,
              quantityLeft: l.quantityLeft,
            ),
        ]);
      });
    });
  }

  Future<void> _record(
    String id,
    String type,
    DateTime at,
    String staffId,
    Map<String, Object?> payload,
  ) => _db
      .into(_db.outboxEntries)
      .insert(
        OutboxEntriesCompanion.insert(
          id: id,
          type: type,
          occurredAt: at.toUtc(),
          actorStaffId: Value(staffId),
          payload: jsonEncode(payload),
        ),
      );

  /// A baker's entry: one lot dated today (M5.1).
  Future<void> produce({
    required String variantId,
    required int quantity,
    required String staffId,
    required DateTime now,
  }) => _record(_uuid.v7(), 'stock.produced', now, staffId, {
    'variantId': variantId,
    'quantity': quantity,
    'producedOn': localDayOf(now),
    'staffId': staffId,
  });

  Future<void> waste({
    required String variantId,
    required int quantity,
    required String reason,
    String? lotId,
    required String staffId,
    required DateTime now,
  }) => _record(_uuid.v7(), 'stock.wasted', now, staffId, {
    'variantId': variantId,
    'quantity': quantity,
    'reason': reason,
    'lotId': lotId,
    'staffId': staffId,
  });

  /// Units on hand per variant; the server works out each difference.
  Future<void> count({
    required Map<String, int> counted,
    required String staffId,
    required DateTime now,
  }) => _record(_uuid.v7(), 'stock.counted', now, staffId, {
    'staffId': staffId,
    'lines': [
      for (final e in counted.entries) {'variantId': e.key, 'counted': e.value},
    ],
  });

  /// Stock by variant today.
  Future<Map<String, VariantStock>> view(DateTime now) async {
    final today = localDayOf(now);
    final rules = <String, CatalogProduct>{};
    final query = _db.select(_db.catalogVariants).join([
      innerJoin(
        _db.catalogProducts,
        _db.catalogProducts.id.equalsExp(_db.catalogVariants.productId),
      ),
    ]);
    for (final r in await query.get()) {
      rules[r.readTable(_db.catalogVariants).id] = r.readTable(
        _db.catalogProducts,
      );
    }

    final lots = <String, List<ViewLot>>{};
    final short = <String, int>{};
    void take(String variantId, int quantity, {String? aged, String? lotId}) {
      final mine = lots[variantId] ?? const <ViewLot>[];
      final pool = lotId == null
          ? mine
          : mine.where((l) => l.id == lotId).toList();
      final r = assignLots(
        [
          for (final l in pool)
            FifoLot(id: l.id, producedOn: l.producedOn, left: l.left),
        ],
        quantity,
        aged,
      );
      for (final (id, units) in r.takes) {
        mine.firstWhere((l) => l.id == id).left -= units;
      }
      if (r.unassigned > 0) {
        short[variantId] = (short[variantId] ?? 0) + r.unassigned;
      }
    }

    for (final l in await _db.select(_db.localLots).get()) {
      (lots[l.variantId] ??= []).add(
        ViewLot(
          id: l.id,
          variantId: l.variantId,
          producedOn: l.producedOn,
          left: l.quantityLeft,
        ),
      );
    }

    for (final r in await _db.pendingOutbox(limit: 100000)) {
      final p = jsonDecode(r.payload) as Map<String, dynamic>;
      switch (r.type) {
        case 'stock.produced':
          final variantId = p['variantId'] as String;
          (lots[variantId] ??= []).add(
            ViewLot(
              id: r.id,
              variantId: variantId,
              producedOn: p['producedOn'] as String,
              left: p['quantity'] as int,
            ),
          );
        case 'stock.wasted':
          take(
            p['variantId'] as String,
            p['quantity'] as int,
            lotId: p['lotId'] as String?,
          );
        case 'sale.completed':
          for (final l in (p['lines'] as List).cast<Map<String, dynamic>>()) {
            final variantId = l['variantId'] as String;
            final after = rules[variantId]?.dayOldDiscountAfterDays;
            take(
              variantId,
              l['quantity'] as int,
              aged: l['dayOld'] == true ? daysBefore(today, after ?? 0) : null,
            );
          }
      }
    }

    return {
      for (final v in {...lots.keys, ...short.keys})
        v: _level(lots[v] ?? const [], short[v] ?? 0, rules[v], today),
    };
  }

  VariantStock _level(
    List<ViewLot> lots,
    int short,
    CatalogProduct? rule,
    String today,
  ) {
    var fresh = 0;
    var dayOld = 0;
    var wasteDue = 0;
    final open = lots.where((l) => l.left > 0).toList();
    for (final l in open) {
      final age = daysBetween(l.producedOn, today);
      if (isDayOld(age, rule?.dayOldDiscountAfterDays)) {
        dayOld += l.left;
      } else {
        fresh += l.left;
      }
      final end = rule?.dayOldWasteAfterDays;
      if (end != null && age >= end) wasteDue += l.left;
    }
    return VariantStock(
      fresh: fresh,
      dayOld: dayOld,
      wasteDue: wasteDue,
      short: short,
      lots: open,
    );
  }

  /// Lots past their last day, oldest first (M6.3).
  Future<List<WasteDue>> wasteList(DateTime now) async {
    final today = localDayOf(now);
    final stock = await view(now);
    final query = _db.select(_db.catalogVariants).join([
      innerJoin(
        _db.catalogProducts,
        _db.catalogProducts.id.equalsExp(_db.catalogVariants.productId),
      ),
    ]);
    final out = <WasteDue>[];
    for (final r in await query.get()) {
      final v = r.readTable(_db.catalogVariants);
      final p = r.readTable(_db.catalogProducts);
      final end = p.dayOldWasteAfterDays;
      if (end == null) continue;
      for (final l in stock[v.id]?.lots ?? const <ViewLot>[]) {
        if (daysBetween(l.producedOn, today) >= end) {
          out.add(WasteDue(lot: l, productName: p.name, variantName: v.name));
        }
      }
    }
    out.sort((a, b) => a.lot.producedOn.compareTo(b.lot.producedOn));
    return out;
  }
}

final stockRepositoryProvider = Provider<StockRepository>(
  (ref) => StockRepository(
    ref.watch(tillDatabaseProvider),
    ref.watch(restClientProvider).stock,
  ),
);

/// Whoever changes stock invalidates this.
final stockViewProvider = FutureProvider<Map<String, VariantStock>>(
  (ref) => ref.watch(stockRepositoryProvider).view(DateTime.now()),
);
