import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/local_database.dart';
import '../domain/ticket.dart';

class HeldTicket {
  const HeldTicket({
    required this.id,
    required this.name,
    required this.heldAt,
    required this.lineCount,
    required this.totalCents,
  });

  final String id;
  final String? name;
  final DateTime heldAt;
  final int lineCount;
  final int totalCents;
}

/// Tickets on hold on this till (M3 brief 4.4). They live in the encrypted
/// local database, so they survive a restart and a change of cashier.
class HeldTicketRepository {
  HeldTicketRepository(this._db, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final Uuid _uuid;

  Future<String> hold(
    Ticket ticket, {
    String? name,
    required String staffId,
    required DateTime now,
  }) async {
    final id = _uuid.v7();
    final trimmed = name?.trim();
    await _db
        .into(_db.localHeldTickets)
        .insert(
          LocalHeldTicketsCompanion.insert(
            id: id,
            name: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
            heldAt: now.toUtc(),
            heldByStaffId: staffId,
            lineCount: ticket.lines.length,
            totalCents: ticket.totals.totalCents,
            ticketJson: jsonEncode(ticket.toJson()),
          ),
        );
    return id;
  }

  /// Newest first.
  Future<List<HeldTicket>> list() async {
    final rows =
        await (_db.select(_db.localHeldTickets)..orderBy([
              (t) => OrderingTerm.desc(t.heldAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
            .get();
    return [
      for (final r in rows)
        HeldTicket(
          id: r.id,
          name: r.name,
          heldAt: r.heldAt,
          lineCount: r.lineCount,
          totalCents: r.totalCents,
        ),
    ];
  }

  /// Takes the ticket off hold and returns it as it was held, or null when
  /// it is no longer there.
  Future<Ticket?> resume(String id) => _db.transaction(() async {
    final row = await (_db.select(
      _db.localHeldTickets,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    await (_db.delete(
      _db.localHeldTickets,
    )..where((t) => t.id.equals(id))).go();
    return Ticket.fromJson(jsonDecode(row.ticketJson) as Map<String, dynamic>);
  });

  /// Throws a held ticket away and records it (`sale.ticket_discarded`).
  Future<void> discard(
    String id, {
    required String staffId,
    required DateTime now,
  }) => _db.transaction(() async {
    final row = await (_db.select(
      _db.localHeldTickets,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.delete(
      _db.localHeldTickets,
    )..where((t) => t.id.equals(id))).go();
    await _db.recordTicketDiscarded(
      staffId: staffId,
      lineCount: row.lineCount,
      amountCents: row.totalCents,
      at: now.toUtc(),
    );
  });
}

final heldTicketRepositoryProvider = Provider<HeldTicketRepository>(
  (ref) => HeldTicketRepository(ref.watch(tillDatabaseProvider)),
);

/// Held tickets for the **En espera** list; invalidated after each change.
final heldTicketsProvider = FutureProvider<List<HeldTicket>>(
  (ref) => ref.watch(heldTicketRepositoryProvider).list(),
);
