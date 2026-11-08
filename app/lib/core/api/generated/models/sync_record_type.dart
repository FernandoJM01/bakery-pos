// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

/// Known types: `audit.offline_event` (payload `OfflineAuditPayload`), `sale.completed`.
/// (payload `SaleCompletedPayload`, record `id` = sale ID) and `sale.refunded` (payload.
/// `SaleRefundedPayload`, record `id` = refund ID), `shift.opened` (payload `ShiftOpenedPayload`, record `id` = shift ID),.
/// `cash.movement` (payload `CashMovementPayload`), `shift.closed` (payload `ShiftClosedPayload`), `stock.produced`.
/// (payload `StockProducedPayload`, record `id` = lot ID), `stock.wasted` (payload `StockWastedPayload`) and `stock.counted`.
/// (payload `StockCountedPayload`) and `order.prepaid`.
/// (payload `OrderPrepaidPayload`, record `id` = prepaid entry ID). The server accepts any string and quarantines.
/// unknown types with `SYNC_UNKNOWN_TYPE`, so an older server never rejects a whole batch.
///
typedef SyncRecordType = String;
