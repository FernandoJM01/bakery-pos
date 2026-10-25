# Milestone 2: Catalog and sync

Status: draft for Fernando, 25 Oct 2026 · Architect: Claude · Plan: [Phase 1 Implementation Plan](https://claude.ai/code/artifact/f7a32ce4-8b1b-427f-89c0-bf6379cbcb5f) (modules M2 and M10) · Sprint 2

This milestone gives the bakery its product catalog and the sync engine every later module rides on. The owner builds the catalog in the back office (categories, products with photos and variants, prices in MXN with tax included, branch prices, tax rates, day-old rules), and every till receives it and keeps it offline. Tills get a durable outbox that delivers records exactly once, quarantines bad ones without blocking the rest, and shows its state on screen.

The first record type the outbox carries is the till's offline audit events (offline logins, lockouts and approvals from M1), so the engine is proven on real data before sales arrive in M3. No selling yet: the till shows the catalog as the read-only product grid that becomes the sale screen in M3.

Everything in the M1 brief (sections 1 to 3: roles, layout, conventions, CI, definition of done) still applies. This brief only adds to it.

---

## 1. Who builds what

| Owner | Scope |
| --- | --- |
| **Dev A, server** | `server/`: catalog tables and endpoints, photo storage, catalog change feed, sync push with inbox and quarantine, offline audit ingestion, deploy changes for the photo volume |
| **Dev B, app** | `app/`: back office catalog, tax and sync screens; till catalog cache, product grid, outbox and sync worker, sync indicator |
| **Architect** | `contracts/openapi.yaml` (version `0.2.0-m2`), this brief, review, acceptance run |

Branches use the `m2/` prefix. Same rules as M1: PRs under about 600 changed lines, CI green, architect review, Fernando merges, contract changes only through an issue labelled `contract`.

## 2. Decisions made for this milestone (each changeable)

- **Money:** integer centavos, tax included (`priceCents`). The tax portion is derived, never stored on the catalog.
- **Tax rates are data, not code.** A `tax_rate` table with kind `IVA` or `IEPS` and the rate in basis points (`1600` = 16%). The owner picks one IVA rate and an optional IEPS rate per product. Seeded with `IVA 0%`, `IVA 16%` and `IEPS 8%` as placeholders until the bakery's accountant confirms the rates per product. The pilot does not start until they do.
- **Every product has at least one variant.** The variant is the thing that is sold and priced (size, flavour). A product with no real variants has one variant named after the product. SKU and barcode live on the variant.
- **No hard deletes.** Categories, products, variants and tax rates are deactivated (`isActive: false`). Tills hide inactive rows. This keeps old sales readable and makes the change feed simple.
- **Change feed by sequence number.** Every insert or update of a catalog row sets `change_seq` from one PostgreSQL sequence (`catalog_change_seq`). A till asks for "everything after N" and stores the last N it applied.
- **Photos** are re-encoded on upload to WebP, at most 800 × 800 px, metadata stripped (with `sharp`), and stored on a Docker volume, not in PostgreSQL. They are served by ID with a long cache header; photo IDs are random and photos are not sensitive, so serving them needs no token.
- **Sync push** uses device-token auth only (like the staff bundle), because records can be queued while nobody is logged in. Each record says which staff member did it.
- **Quarantine review** is owner-only under the existing `settings.manage` permission. No new permission keys.
- **Day-old rule fields** are stored and edited now; the pricing logic that uses them comes in Sprint 5.

## 3. Data model (Dev A)

All tables have `created_at`, `updated_at`; catalog tables also have `change_seq bigint not null` (set by a trigger or in the service on every insert and update, from `catalog_change_seq`) with an index.

| Table | Key columns | Notes |
| --- | --- | --- |
| `tax_rate` | id, kind (`IVA`, `IEPS`), name, rate_bp (0–10000), is_active | Seeded: IVA 0%, IVA 16%, IEPS 8%. A rate in use cannot be deactivated (`CONFLICT`). |
| `category` | id, name (unique among active), sort_order, color (hex, nullable), is_active | |
| `product` | id, category_id, name, description (nullable), unit (`PIECE`, `KG`, `PACKAGE`), photo_id (nullable), iva_rate_id, ieps_rate_id (nullable), day_old_discount_after_days (nullable), day_old_discount_bp (nullable), day_old_waste_after_days (nullable), sort_order, is_active | `iva_rate_id` must be an IVA rate, `ieps_rate_id` an IEPS rate. Day-old: discount days and bp are both set or both null; waste days > discount days when both set. |
| `product_variant` | id, product_id, name, sku (unique, nullable), barcode (unique, nullable), price_cents (> 0), sort_order, is_active | A product keeps at least one active variant while it is active (`CONFLICT`). |
| `branch_price` | variant_id, branch_id, price_cents (> 0), primary key (variant_id, branch_id) | Overrides `price_cents` in that branch. Removing an override is a delete of this row and must still reach tills: keep a `deleted_at` instead of deleting, and give it `change_seq` too. |
| `photo` | id, content_type, bytes, width, height, sha256, created_by | File at `${PHOTO_DIR}/<id>.webp`. |
| `sync_inbox` | record_id (PK, from the till), device_id, type, occurred_at, received_at, status (`APPLIED`, `QUARANTINED`) | One row per record ever received; the primary key is what makes delivery idempotent. |
| `sync_quarantine` | record_id (PK, FK sync_inbox), device_id, branch_id, type, payload (jsonb), error_code, error_message, received_at, resolved_at, resolved_by, resolution_note | Payload kept for review. Never holds PINs. |

Audit (`audit_log`, new actions): `catalog.category_created`, `catalog.category_updated`, `catalog.product_created`, `catalog.product_updated`, `catalog.variant_created`, `catalog.variant_updated`, `catalog.price_changed`, `catalog.branch_price_changed`, `catalog.tax_rate_created`, `catalog.tax_rate_updated`, `sync.quarantine_resolved`. **`catalog.price_changed` and `catalog.branch_price_changed` store `{ old, new }` in centavos (M2.5)**; the update actions store the changed field names and old and new values. Offline events arrive with their own M1 actions plus `data.offline: true`.

## 4. Behaviour

### 4.1 Catalog in the back office
- The owner creates a category, then a product in it with a photo, an IVA rate (IEPS optional), and one to many variants with name, price, and optional SKU and barcode. One form saves the product and its variants together (`POST /v1/products` with `variants`).
- Branch prices: per variant, the owner can set a price for SUC1 or SUC2 that overrides the base price; clearing the field removes the override.
- Searching the product list matches product name, variant name, SKU and barcode; filters by category and active/inactive.
- Duplicate SKU or barcode → `409 CONFLICT` with `details.field`.
- Prices are typed and shown as pesos (`$12.50`) and sent as centavos (`1250`). The form also shows the tax split for the chosen rates. IEPS applies to the base and IVA to the base plus IEPS, so working back from the price, in integer centavos with half-up rounding:
  - `beforeIva = round(price × 10000 / (10000 + ivaBp))`, `iva = price − beforeIva`
  - `base = round(beforeIva × 10000 / (10000 + iepsBp))`, `ieps = beforeIva − base`

  The three parts always add up to the price. Put this in one pure function on each side, tested against the same table of cases (C5); M3 receipts and reports reuse it.

### 4.2 Catalog on the till
- After login and then every sync cycle the till calls `GET /v1/sync/catalog?since=<lastSeq>` with its device token, pages until `hasMore` is false, applies each page in one local transaction, then stores `nextSince`. First run uses `since=0`.
- The server returns only what the device's branch needs: all categories, products, variants and tax rates, and only the `branch_price` rows of that branch. The till computes the effective price as the branch price when present, else the base price.
- Photos are downloaded once by ID and cached on disk; a missing photo shows the category color and initials, never a broken image.
- The till home becomes the **product grid** from the approved wireframe: category tabs, photo tiles with name and price, search by name, SKU or barcode. Tapping a tile does nothing yet (M3 adds the cart). Inactive rows are hidden.

### 4.3 Outbox and sync on the till
- Every record the till must deliver is written to a local `outbox` table in the same transaction as the change it describes: `id` (UUID v7, the idempotency key), `type`, `occurredAt`, `actorStaffId`, `payload` (JSON), `attempts`, `status` (`PENDING`, `QUARANTINED`), `lastErrorCode`.
- A sync worker runs every 15 seconds while the app is open, and at once after login and after reconnecting. Each cycle: push pending records oldest first in batches of up to 100, then pull the catalog. Failures back off 15 s, 30 s, 60 s, then stay at 60 s.
- Per record result from the server: `APPLIED` or `DUPLICATE` → delete from the outbox; `QUARANTINED` → mark quarantined and stop sending it. A network error or `5xx` leaves everything pending. One bad record never stops the others.
- `401 DEVICE_REVOKED` or `DEVICE_UNKNOWN` follows the M1 rule (wipe and return to enrollment).
- The top bar shows **En línea** or **Sin conexión**, the number of records waiting, and a warning badge with the number quarantined. Online means the last request to the server succeeded within 45 seconds.
- **M2 record type: `audit.offline_event`.** Every offline login success, failure, lockout and offline approval from M1 (the till already keeps approvals in `OfflineApprovalEntries`) goes into the outbox instead of only local tables.

### 4.4 Sync on the server
- `POST /v1/sync/push` accepts up to 100 records. For each, in its own transaction: insert into `sync_inbox` with `ON CONFLICT (record_id) DO NOTHING`. Conflict → result `DUPLICATE` (or `QUARANTINED` again if that record is in quarantine). New → apply it by type; any validation or business error rolls back that record's work and writes `sync_quarantine` with a stable error code. Other records in the batch still apply.
- Unknown `type` → `SYNC_UNKNOWN_TYPE`. Payload that fails the type's schema → `SYNC_INVALID_PAYLOAD`. Staff not in the device's branch, or approver without the permission → `SYNC_REJECTED`.
- `audit.offline_event` writes one `audit_log` row with `occurred_at` from the record, `device_id` and `branch_id` from the token, actor and approver from the payload and `data.offline = true`.
- Batch-level errors (bad body, more than 100 records) → `400 VALIDATION_FAILED` and nothing applies. The push endpoint is rate-limited per device (60 requests a minute).
- Back office **Sincronización** screen: quarantined records newest first with device, type, time, error code and message, payload shown as formatted JSON; the owner can mark one resolved with a note. Resolving never re-applies the record in M2.

## 5. Screens

Back office (owner):
- **Catálogo:** category list (create, rename, color, reorder, deactivate); product list with search and filters; product form (photo upload with preview, category, unit, IVA and IEPS selects, day-old fields, variants table with add/remove, branch price per variant, tax split preview).
- **Impuestos** (under Ajustes): list of tax rates, add, rename, deactivate.
- **Sincronización:** quarantine list and resolve dialog, plus a list of devices with their last sync time (`lastSeenAt`).

Till: the product grid as the home for cashiers and managers (bakers keep their production placeholder), the sync indicator in the top bar, and a **Sincronización** sheet opened from the indicator with waiting and quarantined counts and a "Sincronizar ahora" button.

All text in `app_es.arb`. Follow the approved wireframes ([design](https://claude.ai/artifact/PMKvvJ6PdGV57koaPLyv4J)) for the grid tiles and photo slots.

## 6. Deploy changes (Dev A)

- New volume `photos` mounted at `PHOTO_DIR` in the server container; `PHOTO_DIR` is required configuration.
- `deploy/backup.sh` archives the photo directory next to the database dump, `restore.sh` restores both, and the CI deploy job checks a photo survives backup and restore.
- Upload limit: 5 MB before re-encoding; accepted types JPEG, PNG and WebP (checked by content, not by extension).

## 7. Acceptance tests

Each must exist as an automated test named with its ID unless marked manual.

| # | Test | Maps to |
| --- | --- | --- |
| C1 | Owner creates a product with 3 variants and a photo in one request; manager or cashier gets 403 on every catalog write | M2.1 |
| C2 | Duplicate SKU or barcode across variants → 409 `CONFLICT` with `details.field` | M2.1 |
| C3 | A till pulling from `since=0` receives the new product; a second pull with the returned `nextSince` returns nothing; after an edit it returns only the edited rows | M2.1, M10.1 |
| C4 | A SUC1 till receives SUC1 branch prices and never SUC2's; removing an override reaches the till and the base price applies again | M2.2 |
| C5 | Tax split: `$10.00` with IVA 16% → base 8.62, IVA 1.38; `$10.00` with IEPS 8% and IVA 16% → base 7.98, IEPS 0.64, IVA 1.38; same results on server and app (shared table of cases) | M2.2, M2.3 |
| C6 | An IEPS rate cannot be set as a product's IVA rate; a rate in use cannot be deactivated | M2.3 |
| C7 | Day-old fields: discount days without percentage → 400; waste days ≤ discount days → 400 | M2.4 |
| C8 | Every price change writes one `catalog.price_changed` audit row with actor, old and new centavos; branch price changes likewise | M2.5 |
| C9 | Pushing the same record twice → `APPLIED` then `DUPLICATE`, and exactly one audit row | M10.2 |
| C10 | A batch of 10 records with one invalid → 9 `APPLIED`, 1 `QUARANTINED` with its code; the owner sees it in the quarantine list and can resolve it | M10.3 |
| C11 | Till offline: 3 offline logins and 1 offline approval queue in the outbox; after reconnecting they reach the server within one sync cycle as audit rows with `data.offline: true` | M10.1 |
| C12 | Sync worker: a network error leaves records pending and backs off; a quarantined record stops being sent while the others continue (unit test with a fake API) | M10.3 |
| C13 | The top bar shows online/offline, the waiting count and the quarantined count, and they change as the outbox changes (widget test) | M10.4 |
| C14 | Upload: a 4 MB JPEG becomes a WebP of at most 800 px without EXIF; a renamed text file is refused with 400 | M2.1 |
| C15 | Photos and database survive backup and restore in the CI deploy job | Ops |
| C16 | Manual: with two tills enrolled, the owner creates a product with 3 variants in under 2 minutes and it appears on both tills within 30 seconds | M2.1 |

## 8. Out of scope for M2

Cart, payments, sales records, receipts, stock, day-old pricing logic, CSV import of the catalog, modifiers and combos, weighed goods with a scale. Do not add sale tables yet.

## 9. Open for Fernando

- The accountant's IVA and IEPS rate for each product family (placeholders until then; the pilot needs the real ones).
- Whether branch prices are needed at all at the start (built either way; leave them empty if not).
