// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

/// Known types: `audit.offline_event` (payload `OfflineAuditPayload`), `sale.completed`.
/// (payload `SaleCompletedPayload`, record `id` = sale ID) and `sale.refunded` (payload.
/// `SaleRefundedPayload`, record `id` = refund ID), `shift.opened` (payload `ShiftOpenedPayload`, record `id` = shift ID),.
/// `cash.movement` (payload `CashMovementPayload`) and `shift.closed` (payload `ShiftClosedPayload`). The server accepts any string and quarantines.
/// unknown types with `SYNC_UNKNOWN_TYPE`, so an older server never rejects a whole batch.
///
typedef SyncRecordType = String;
