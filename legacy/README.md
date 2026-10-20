# 🥖 POS Bakery — Enterprise Offline-First Point of Sale

[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-blue.svg)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.3-red.svg)](https://nestjs.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED.svg)](https://docker.com)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20%26%20Offline--First-success.svg)]()

Enterprise-grade, offline-first Point of Sale (POS) system designed for multi-branch artisan bakeries. Ensures uninterrupted cashier and baking operations with zero network dependency, seamless background syncing, and conflict-free event sourcing.

---

## 🚀 Quick Start (Dockerized Backend)

### 1. Prerequisites
- [Docker & Docker Compose](https://www.docker.com/) (Installed and running)
- [Flutter SDK](https://flutter.dev/) (For running the mobile/tablet client)
- **Note**: No local `node` or `npm` required. All NestJS dependencies and compilation are encapsulated in Docker.

### 2. Start Cloud Backend & PostgreSQL
```bash
docker compose up -d --build
```
This automatically initializes:
- **PostgreSQL 16** with extensions and seed data on port `5433` (internal `5432`)
- **NestJS Cloud Backend** on `http://localhost:3001`
- Seed branch: `Downtown Bakery Oven #1 (BR-01)`
- Seed users: PIN `1234` for Cashier (`cashier1`), Baker (`baker1`), Manager (`manager1`), and Admin (`admin`).

To verify health:
```bash
curl http://localhost:3001/products
```

To run backend tests inside Docker:
```bash
docker compose exec pos_backend npm test
```

---

## 📱 Running the Flutter POS Client

```bash
cd pos_mobile_app
flutter pub get
flutter run -d macos # or -d chrome, -d ipad / android
```

To run all Flutter unit and widget tests:
```bash
flutter test
```

---

## 🏛️ Architecture Highlights

### 1. Clean Architecture Layers
- **Presentation**: Touch-optimized Flutter UI widgets (`PinLoginScreen`, `CashierDashboardScreen`, `BakerAddBatchScreen`) with touch targets >= 56dp, dark-mode retail palette, and Riverpod Notifiers (`StockNotifier`, `CartNotifier`, `CheckoutNotifier`).
- **Domain**: Pure business entities (`Product`, `User`, `LedgerEvent`, `CartItem`) and hardware interfaces (`PaymentGatewayPlugin`, `ReceiptPrinterService`).
- **Data**: SQLite repositories (`InventoryRepositoryImpl`, `CatalogRepositoryImpl`, `AuthRepositoryImpl`) and `BackgroundSyncWorker`.

### 2. Event Sourcing & Offline-First Guarantees
- Local SQLite database writes return instantaneously (<16ms) to keep 60fps responsiveness.
- Background worker pushes batched JSON arrays to `/sync/push`.
- PostgreSQL processes events inside atomic transactions using `ON CONFLICT (branch_id, client_event_id) DO NOTHING` for idempotency and arithmetic balance UPSERTs.

---

## 📚 Documentation
- [System Architecture Overview](docs/architecture/system_overview.md)
- [Offline Sync & Event Sourcing Protocol](docs/sync/sync_protocol.md)

---

## 👥 Roles
| Role | Identifier | Capabilities |
| :--- | :--- | :--- |
| **Global Admin** | `GLOBAL_ADMIN` | Full multi-branch access, master catalogs, user roles |
| **Branch Manager** | `BRANCH_MANAGER` | Branch management, shift reconciliations, inventory audits |
| **Cashier** | `CASHIER` | High-speed POS ticket management, cash payments, change calculation |
| **Local Baker** | `LOCAL_BAKER` | Touch-optimized batch production entry (`+1 Tray`, `+2 Trays`, `+1 Oven`) |
