import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/sync_push_request.dart';
import '../../../core/api/generated/models/sync_record.dart';
import '../../../core/api/generated/models/sync_result_status.dart';
import '../../../core/api/generated/sync/sync_api_client.dart';
import '../../../core/storage/local_database.dart';
import '../../orders/data/orders_repository.dart';
import '../../stock/data/stock_repository.dart';
import '../../till_catalog/data/till_catalog_repository.dart';

/// Delivers the outbox and refreshes the catalog (M2 brief 4.3).
///
/// Every cycle pushes pending records oldest first in batches of up to 100,
/// then pulls the catalog. A cycle runs every 15 seconds while the app is
/// open, at once when started (after login) and on [syncNow]. Failures back
/// off 15, 30, then 60 seconds and stay at 60 until a cycle succeeds.
class SyncWorker extends ChangeNotifier {
  SyncWorker({
    required this.db,
    required this.api,
    required this.catalog,
    this.stock,
    this.orders,
    DateTime Function()? clock,
    this.onCatalogUpdated,
    this.onStockUpdated,
    this.onOrdersUpdated,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final SyncApiClient api;
  final TillCatalogRepository catalog;
  final DateTime Function() _clock;
  final VoidCallback? onCatalogUpdated;
  final StockRepository? stock;
  final VoidCallback? onStockUpdated;
  final OrdersRepository? orders;
  final VoidCallback? onOrdersUpdated;

  static const interval = Duration(seconds: 15);
  static const _backoff = [
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];
  static const onlineWindow = Duration(seconds: 45);
  static const batchSize = 100;

  Timer? _timer;
  Future<bool>? _running;
  int _failures = 0;
  DateTime? _lastSuccessAt;
  bool _disposed = false;

  /// When the next cycle is due after the last one.
  Duration get nextDelay =>
      _failures == 0 ? interval : _backoff[(_failures - 1).clamp(0, 2)];

  int get consecutiveFailures => _failures;

  /// Online means the last request to the server succeeded within 45 s.
  bool get isOnline =>
      _lastSuccessAt != null &&
      _clock().difference(_lastSuccessAt!) <= onlineWindow;

  /// Starts the loop with an immediate cycle.
  void start() {
    if (_timer != null || _disposed) return;
    _schedule(Duration.zero);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Runs a cycle now (the "Sincronizar ahora" button, or a reconnect).
  Future<bool> syncNow() async {
    final ok = await runCycle();
    if (_timer != null) _schedule(nextDelay);
    return ok;
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () async {
      await runCycle();
      if (_timer != null && !_disposed) _schedule(nextDelay);
    });
  }

  /// One push-then-pull cycle; returns whether the server was reached.
  /// Overlapping calls share the cycle already running.
  Future<bool> runCycle() => _running ??= _cycle().whenComplete(() {
    _running = null;
  });

  Future<bool> _cycle() async {
    try {
      await _pushAll();
      final applied = await catalog.pull();
      if (applied > 0) onCatalogUpdated?.call();
      await stock?.pull();
      onStockUpdated?.call();
      await orders?.pull();
      onOrdersUpdated?.call();
      _failures = 0;
      _lastSuccessAt = _clock();
      return true;
    } catch (_) {
      // Network errors, 5xx and refusals all leave the outbox as it is.
      // DEVICE_REVOKED is handled by the device interceptor (M1 rule).
      _failures++;
      return false;
    } finally {
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _pushAll() async {
    for (;;) {
      final batch = await db.pendingOutbox(limit: batchSize);
      if (batch.isEmpty) return;
      await db.batch((b) {
        for (final r in batch) {
          b.update(
            db.outboxEntries,
            OutboxEntriesCompanion(attempts: Value(r.attempts + 1)),
            where: (o) => o.id.equals(r.id),
          );
        }
      });
      final res = await api.pushRecords(
        body: SyncPushRequest(
          records: [
            for (final r in batch)
              SyncRecord(
                id: r.id,
                type: r.type,
                occurredAt: r.occurredAt.toUtc(),
                actorStaffId: r.actorStaffId,
                payload: jsonDecode(r.payload),
              ),
          ],
        ),
      );
      _lastSuccessAt = _clock();
      final delivered = <String>[];
      await db.transaction(() async {
        for (final result in res.results) {
          switch (result.status) {
            case SyncResultStatus.applied:
            case SyncResultStatus.duplicate:
              delivered.add(result.id);
            case SyncResultStatus.quarantined:
              await (db.update(
                db.outboxEntries,
              )..where((o) => o.id.equals(result.id))).write(
                OutboxEntriesCompanion(
                  status: const Value('QUARANTINED'),
                  lastErrorCode: Value(result.errorCode),
                ),
              );
            case SyncResultStatus.$unknown:
              break;
          }
        }
        await (db.delete(
          db.outboxEntries,
        )..where((o) => o.id.isIn(delivered))).go();
      });
      // A batch the server answered without settling anything would loop.
      if (res.results.isEmpty || batch.length < batchSize) return;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }
}

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final worker = SyncWorker(
    db: ref.watch(tillDatabaseProvider),
    api: ref.watch(restClientProvider).sync,
    catalog: ref.watch(tillCatalogRepositoryProvider),
    stock: ref.watch(stockRepositoryProvider),
    onCatalogUpdated: () => ref.invalidate(tillCatalogProvider),
    onStockUpdated: () => ref.invalidate(stockViewProvider),
    orders: ref.watch(ordersRepositoryProvider),
    onOrdersUpdated: () => ref.invalidate(todayTicketsProvider),
  );
  ref.onDispose(worker.dispose);
  return worker;
});

/// Whether the till home starts the worker. Widget tests of the shell turn
/// it off: a background cycle there would race the scenario being tested.
final syncAutoStartProvider = Provider<bool>((ref) => true);

/// Waiting and quarantined counts from the outbox, live.
final outboxCountsProvider = StreamProvider<({int pending, int quarantined})>(
  (ref) => ref.watch(tillDatabaseProvider).watchOutboxCounts(),
);
