# 🔄 Event Sourcing & Offline Sync Protocol

## 1. Idempotent Append-Only Ledger

### Edge Generation
When a transaction occurs offline on a Flutter terminal:
1. The app generates a cryptographically random UUIDv4 (`client_event_id`).
2. The action is classified into a `LedgerEventType`:
   - `BAKE_BATCH_PRODUCED` (Quantity positive)
   - `SALE_COMPLETED` (Quantity negative)
   - `REFUND_RETURNED` (Quantity positive)
   - `WASTE_DISCARDED` (Quantity negative)
3. The event is written inside a local SQLite transaction to `sync_queue_ledger` (`sync_status = 'PENDING'`) while updating `local_inventory_balances` instantaneously.

### Cloud Ingestion (`POST /sync/push`)
```json
{
  "branch_id": "a0000000-0000-0000-0000-000000000001",
  "terminal_id": "REG-01",
  "events": [
    {
      "client_event_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "branch_id": "a0000000-0000-0000-0000-000000000001",
      "terminal_id": "REG-01",
      "event_type": "SALE_COMPLETED",
      "user_id": "b0000000-0000-0000-0000-000000000001",
      "product_id": "c0000000-0000-0000-0000-000000000001",
      "quantity_change": -2,
      "reference_id": "ORD-A1B2C3D4",
      "client_timestamp": "2026-10-11T08:30:00.000Z"
    }
  ]
}
```

### PostgreSQL Atomic Transaction Algorithm
```sql
BEGIN;

-- 1. Insert Event (Idempotent: if already received, returns 0 rows)
INSERT INTO inventory_ledger (
  client_event_id, branch_id, terminal_id, event_type,
  user_id, product_id, quantity_change, batch_number,
  reference_id, metadata, client_timestamp
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
ON CONFLICT (branch_id, client_event_id) DO NOTHING
RETURNING id;

-- 2. If row was inserted (fresh event):
INSERT INTO inventory_balances (
  branch_id, product_id, current_stock, last_event_id, last_updated_at
) VALUES ($branch_id, $product_id, $quantity_change, $event_id, NOW())
ON CONFLICT (branch_id, product_id) DO UPDATE SET
  current_stock = inventory_balances.current_stock + EXCLUDED.current_stock,
  last_event_id = EXCLUDED.last_event_id,
  last_updated_at = NOW();

COMMIT;
```

## 2. Collision & Network Recovery Handling
- **Duplicate Push**: If a network timeout occurs right after PostgreSQL commits but before Flutter receives the HTTP 200 response, Flutter will resend the batch on next retry. PostgreSQL's `ON CONFLICT (branch_id, client_event_id) DO NOTHING` prevents double-counting balances, and reports back `accepted_count: 0, duplicate_count: 1`.
- **Clock Drift**: Client events record `client_timestamp` for audit chronology, while PostgreSQL records `server_timestamp` for deterministic ordering across branches.
