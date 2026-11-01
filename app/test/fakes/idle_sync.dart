import 'package:bakery_pos/features/sync/data/sync_worker.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Overrides for shell widget tests: no background sync cycles, and an
/// empty outbox count instead of a live Drift stream (whose close timer
/// would outlive the widget tree under fake async).
final idleSyncOverrides = <Override>[
  syncAutoStartProvider.overrideWithValue(false),
  outboxCountsProvider.overrideWith(
    (ref) => Stream.value((pending: 0, quarantined: 0)),
  ),
];
