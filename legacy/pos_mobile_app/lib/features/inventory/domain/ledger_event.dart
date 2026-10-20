enum LedgerEventType {
  bakeBatchProduced('BAKE_BATCH_PRODUCED'),
  saleCompleted('SALE_COMPLETED'),
  refundReturned('REFUND_RETURNED'),
  wasteDiscarded('WASTE_DISCARDED'),
  transferIn('TRANSFER_IN'),
  transferOut('TRANSFER_OUT'),
  auditAdjustment('AUDIT_ADJUSTMENT');

  final String value;
  const LedgerEventType(this.value);

  static LedgerEventType fromString(String val) {
    return LedgerEventType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => LedgerEventType.saleCompleted,
    );
  }
}

class LedgerEvent {
  final String clientEventId;
  final String branchId;
  final String terminalId;
  final LedgerEventType eventType;
  final String userId;
  final String productId;
  final int quantityChange;
  final String? batchNumber;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime clientTimestamp;
  final String syncStatus; // PENDING, SYNCING, SYNCED, FAILED
  final int retryCount;

  const LedgerEvent({
    required this.clientEventId,
    required this.branchId,
    required this.terminalId,
    required this.eventType,
    required this.userId,
    required this.productId,
    required this.quantityChange,
    this.batchNumber,
    this.referenceId,
    this.metadata,
    required this.clientTimestamp,
    this.syncStatus = 'PENDING',
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'client_event_id': clientEventId,
    'branch_id': branchId,
    'terminal_id': terminalId,
    'event_type': eventType.value,
    'user_id': userId,
    'product_id': productId,
    'quantity_change': quantityChange,
    'batch_number': batchNumber,
    'reference_id': referenceId,
    'metadata': metadata != null ? metadata.toString() : null,
    'client_timestamp': clientTimestamp.millisecondsSinceEpoch,
    'sync_status': syncStatus,
    'retry_count': retryCount,
    'created_at': DateTime.now().millisecondsSinceEpoch,
  };

  Map<String, dynamic> toApiJson() => {
    'client_event_id': clientEventId,
    'branch_id': branchId,
    'terminal_id': terminalId,
    'event_type': eventType.value,
    'user_id': userId,
    'product_id': productId,
    'quantity_change': quantityChange,
    if (batchNumber != null) 'batch_number': batchNumber,
    if (referenceId != null) 'reference_id': referenceId,
    'client_timestamp': clientTimestamp.toIso8601String(),
  };

  factory LedgerEvent.fromMap(Map<String, dynamic> map) => LedgerEvent(
    clientEventId: map['client_event_id'] as String,
    branchId: map['branch_id'] as String,
    terminalId: map['terminal_id'] as String,
    eventType: LedgerEventType.fromString(map['event_type'] as String),
    userId: map['user_id'] as String,
    productId: map['product_id'] as String,
    quantityChange: map['quantity_change'] as int,
    batchNumber: map['batch_number'] as String?,
    referenceId: map['reference_id'] as String?,
    clientTimestamp: DateTime.fromMillisecondsSinceEpoch(map['client_timestamp'] as int),
    syncStatus: (map['sync_status'] ?? 'PENDING') as String,
    retryCount: (map['retry_count'] ?? 0) as int,
  );
}
