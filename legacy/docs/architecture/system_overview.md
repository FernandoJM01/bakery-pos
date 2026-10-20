# 🥖 POS Bakery — Enterprise Offline-First Architecture

## 1. Executive Architecture Summary
POS Bakery is an enterprise-grade, offline-first Point of Sale solution built specifically for multi-branch artisanal bakeries. It guarantees:
- **Zero-Latency POS Operations**: All sales, returns, and baking batch arrivals write immediately to local SQLite edge databases, keeping UI interactions at 60fps.
- **Append-Only Event Ledger (Event Sourcing)**: Transactions are never mutated directly. Every business action emits an immutable event.
- **Zero Sync Data Collisions**: Offline events are queued in an SQLite outbox. When internet connectivity is restored, events are pushed in batches to the cloud NestJS backend. PostgreSQL processes them inside atomic database transactions using idempotent conflict handling (`ON CONFLICT (branch_id, client_event_id) DO NOTHING`) and atomic arithmetic balance UPSERTs.

---

## 2. System Architecture Diagram

```
+-----------------------------------------------------------------------------------+
|                           EDGE LAYER (Flutter Tablet)                             |
|                                                                                   |
|  +--------------------+        +---------------------+        +----------------+  |
|  |   PinLoginScreen   |  --->  | CashierDashboard    |  --->  | CartNotifier   |  |
|  +--------------------+        +---------------------+        +----------------+  |
|                                                                       |           |
|  +--------------------+        +---------------------+                v           |
|  | BakerAddBatchScreen|  --->  | StockNotifier (UI)  |  <---  [CheckoutNotifier]  |
|  +--------------------+        +---------------------+                |           |
|                                           |                           |           |
|                                           v                           v           |
|                             +----------------------------------------------+      |
|                             |        Local SQLite Database (sqflite)       |      |
|                             |  - local_inventory_balances (Instant UI)     |      |
|                             |  - sync_queue_ledger        (Outbox Queue)   |      |
|                             |  - cached_users & cached_products            |      |
|                             +----------------------------------------------+      |
|                                                    |                              |
|                                                    v                              |
|                                      [BackgroundSyncWorker]                       |
+----------------------------------------------------+------------------------------+
                                                     |
                                           HTTP POST /sync/push
                                           (Batched JSON Events)
                                                     |
+----------------------------------------------------v------------------------------+
|                          CLOUD LAYER (NestJS & PostgreSQL)                        |
|                                                                                   |
|        +-----------------------------------------------------------------+        |
|        |                  NestJS Backend (Node.js 20)                    |        |
|        |  - SyncController   -> POST /sync/push, GET /sync/pull/:branch  |        |
|        |  - AuthController   -> POST /auth/login-pin                     |        |
|        |  - ProductsController -> GET /products                          |        |
|        +-----------------------------------------------------------------+        |
|                                           |                                       |
|                                   BEGIN TRANSACTION                               |
|                                           |                                       |
|                                           v                                       |
|        +-----------------------------------------------------------------+        |
|        |                      PostgreSQL 16 Engine                       |        |
|        |                                                                 |        |
|        |  1. inventory_ledger (Append-Only Event Sourcing)               |        |
|        |     CONSTRAINT uq_branch_client_event (branch_id, client_event) |        |
|        |     -> Idempotent insertion: ON CONFLICT DO NOTHING             |        |
|        |                                                                 |        |
|        |  2. inventory_balances (Materialized Balance Table)             |        |
|        |     UPSERT: ON CONFLICT (branch_id, product_id)                 |        |
|        |     DO UPDATE current_stock = current_stock + EXCLUDED.change   |        |
|        +-----------------------------------------------------------------+        |
|                                           |                                       |
|                                   COMMIT TRANSACTION                              |
+-----------------------------------------------------------------------------------+
```

---

## 3. Technology Stack Breakdown
| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Terminal Frontend** | Flutter (Dart 3.13) + Riverpod 2.6 | Cross-platform touch performance, rock-solid state management, strict Clean Architecture |
| **Edge Storage** | SQLite (`sqflite` / `sqflite_common_ffi`) | Sub-millisecond local reads/writes, zero reliance on active network |
| **Cloud API** | NestJS (TypeScript) inside Docker | Modular Dependency Injection, high throughput, enterprise maintainability |
| **Containerization** | Docker & Docker Compose | Host machine isolation (**Zero local npm or Node required**) |
| **Cloud Database** | PostgreSQL 16 | Relational consistency, atomic row locking, JSONB metadata, robust UPSERT support |
| **Hardware Abstraction** | Dart FFI / ESC/POS socket protocol | Ready for thermal printers (9100 TCP/IP) and future EMV / Stripe terminals |

---

## 4. Role-Based Access Control (RBAC)
1. **Global Admin (`GLOBAL_ADMIN`)**: Unrestricted access across all company branches, financial audits, catalog definitions, and employee permissions.
2. **Branch Manager (`BRANCH_MANAGER`)**: Branch-specific reporting, cashier shift audits, and stock adjustments.
3. **Cashier (`CASHIER`)**: Fast POS terminal access, register transactions, order receipts, cash drawer operations.
4. **Local Baker (`LOCAL_BAKER`)**: Fast touch batch production registration (`+1 Tray`, `+2 Trays`, `+1 Oven`) with automatic lot identification.
