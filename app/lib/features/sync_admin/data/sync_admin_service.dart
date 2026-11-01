import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../../../core/api/generated/models/device.dart';
import '../../../core/api/generated/models/quarantine_entry.dart';
import '../../../core/api/generated/models/quarantine_resolve.dart';
import '../../../core/api/generated/models/status.dart';
import '../../../core/api/generated/sync/sync_api_client.dart';

/// One loaded run of the quarantine list, newest first.
class QuarantineList {
  const QuarantineList({required this.items, this.nextCursor});

  final List<QuarantineEntry> items;
  final String? nextCursor;
}

/// Which quarantine records the screen shows.
final quarantineFilterProvider =
    NotifierProvider<QuarantineFilterNotifier, Status>(
      QuarantineFilterNotifier.new,
    );

class QuarantineFilterNotifier extends Notifier<Status> {
  @override
  Status build() => Status.open;

  void set(Status status) => state = status;
}

/// The quarantine list for one filter. Each filter has its own notifier, so
/// a late answer for an old filter never replaces the current list.
final quarantineListProvider = AsyncNotifierProvider.autoDispose
    .family<QuarantineListNotifier, QuarantineList, Status>(
      QuarantineListNotifier.new,
    );

class QuarantineListNotifier extends AsyncNotifier<QuarantineList> {
  QuarantineListNotifier(this.status);

  final Status status;
  static const pageSize = 50;
  bool _loadingMore = false;

  SyncApiClient get _api => ref.read(restClientProvider).sync;

  @override
  Future<QuarantineList> build() async {
    final page = await _api.listQuarantine(status: status, limit: pageSize);
    return QuarantineList(items: page.items, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current?.nextCursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _api.listQuarantine(
        status: status,
        cursor: current!.nextCursor,
        limit: pageSize,
      );
      state = AsyncValue.data(
        QuarantineList(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }

  /// Marks a record resolved. It is never re-applied (M2 brief 4.3).
  Future<void> resolve(String recordId, String note) async {
    final resolved = await _api.resolveQuarantine(
      recordId: recordId,
      body: QuarantineResolve(note: note),
    );
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      QuarantineList(
        items: [
          for (final e in current.items)
            if (e.recordId != recordId)
              e
            else if (status != Status.open)
              resolved,
        ],
        nextCursor: current.nextCursor,
      ),
    );
  }
}

/// Devices with their last contact, which is their last sync.
final syncDevicesProvider = FutureProvider.autoDispose<List<Device>>(
  (ref) => ref.read(restClientProvider).devices.listDevices(),
);
