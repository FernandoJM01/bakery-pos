# Milestone 5: Stock and day-old bread

Status: draft for Fernando, 2 Nov 2026 · Architect and builder: Claude · Plan: [Phase 1 Implementation Plan](https://claude.ai/code/artifact/f7a32ce4-8b1b-427f-89c0-bf6379cbcb5f) (modules M5 and M6) · Sprint 5

This milestone tells each branch what bread it has and how old it is. The baker records what comes out of the oven in 2 taps, and each entry becomes a dated lot. Sales take the oldest stock first. Bread past its day shows on the till as a second, cheaper button, and bread past its last day appears on the manager's waste list. Waste, transfers between branches and stock counts all change stock the same way: through a ledger of events that can never be edited. A nightly check proves that stock on hand equals the sum of its events, for every product and branch.

Everything in the M1 to M4 briefs still applies. This brief only adds to it.

---

## 1. Who builds what

Fernando asked on 1 Nov 2026 for Claude to build the milestones itself for now, without prompts for the external developers. The split below still decides the branches.

| Area | Scope |
| --- | --- |
| **Server** | Lot and ledger tables, sync handlers for production, waste and counts, oldest-first assignment of sales, transfers, stock feed for tills, nightly ledger check, waste report |
| **App** | Production screen, day-old buttons on the sale screen, stock view, waste and count flows, transfer send and receive, back office Inventario |
| **Contract** | `contracts/openapi.yaml` version `0.5.0-m5`, `contracts/fixtures/stock-fifo-cases.json`, this brief |

Branches use the `m5/` prefix.

## 2. Decisions made for this milestone (each changeable)

- **The ledger is the truth.** Every stock change is a row in `stock_event`, which `pos_app` can only insert. Stock on hand is the sum of events. `stock_lot.quantity_left` is a stored shortcut that the nightly check compares against the ledger.
- **A sale is never blocked by stock.** Tills sell offline, and the bread in front of the cashier is more real than any number. A till warns when it thinks stock has run out (M3.7, moved here), but the sale goes through.
- **The server assigns lots.** Two tills offline cannot agree on who took the oldest bread, so a till only says what it sold and whether it was day-old. On sync, the server takes the units from the oldest lots of that branch (M5.2), in the order sales arrive.
- **Stock can go negative.** A sale with no lot left to take from writes an event with no lot. On-hand shows below zero, which tells the manager that a production entry is missing. Later production does not repay it automatically; a stock count settles it.
- **Whole units.** Stock uses integer units, like sales. Trays are entered as trays and stored as units through `units_per_tray` on the product variant.
- **Age in calendar days at the branch.** A lot's age is the branch's local date today minus its production date. A lot is day-old when age ≥ the product's `dayOldDiscountAfterDays`, and is on the waste list when age ≥ `dayOldWasteAfterDays`. So with 1 day, yesterday's bread is day-old from midnight.
- **Day-old price.** `round(price × (10000 − dayOldDiscountBp) / 10000)`, half up, from the effective branch price. It applies automatically and is not a discount: it needs no reason or approval and does not count against the cashier's limit. A cashier discount can still go on top.
- **Two buttons only when both exist.** A product shows its day-old button only when the till's stock view holds day-old units. The server validates the arithmetic, not whether day-old stock existed, because the till may have been offline.
- **Cost for the waste report.** There are no recipes yet, so each variant gets an optional `costCents`, typed by the owner. Waste with no cost shows a dash, not $0.00. Recipe costing arrives with ingredients in Phase 2.
- **Bakers enter on a production station or any till.** `stock.production_entry` is the check, so both device types can do it. Each entry is a sync record, so it works offline.
- **Waste reasons:** `BURNT`, `EXPIRED`, `DAMAGED`, `UNSOLD`. Waste takes from the oldest lots unless a lot is chosen from the waste list.
- **Refunds marked "vuelve al inventario"** return units to the lots they came from, newest first; units sold with no lot come back with no lot. Refunds not marked change nothing: the bread is gone.
- **Transfers.** The sender records what left; stock leaves that branch at once and is in transit, belonging to neither. The receiver records what arrived, which may differ, and only then does it enter their stock. A difference is flagged and audited. Lots keep their production date across branches, so old bread stays old.
- **Stock counts.** A manager counts one product or the whole shop by entering units on hand per variant. The difference becomes a `COUNT_ADJUST` event with who and when. A count is not blind.
- **Nightly check.** At 03:00 server time a job sums the ledger per variant, branch and lot and compares it with stored stock. A mismatch writes `stock.ledger_mismatch` to the audit log and shows on Inventario. It never corrects anything by itself.

## 3. Data model (server)

| Table | Key columns | Notes |
| --- | --- | --- |
| `product_variant` (changed) | + `cost_cents` nullable, + `units_per_tray` nullable | Owner-set. |
| `stock_lot` | id (from the device), branch_id, variant_id, produced_on (date), quantity_left, created_at | One per production entry. |
| `stock_event` | id, branch_id, variant_id, lot_id (nullable), kind, quantity (signed), reference_type, reference_id, staff_id, occurred_at | Kinds: `PRODUCTION`, `SALE`, `REFUND_RETURN`, `WASTE`, `TRANSFER_OUT`, `TRANSFER_IN`, `COUNT_ADJUST`. Insert-only for `pos_app`. |
| `stock_waste` | id (from the device), branch_id, variant_id, quantity, reason, staff_id, occurred_at, cost_cents (copied) | One row per waste entry; its events carry the lots. |
| `stock_transfer` | id, from_branch_id, to_branch_id, status (`SENT`, `RECEIVED`), sent_by, sent_at, received_by, received_at, flagged | |
| `stock_transfer_line` | transfer_id, variant_id, lot_produced_on, quantity_sent, quantity_received | |
| `stock_count` | id, branch_id, staff_id, occurred_at | With `stock_count_line`: variant_id, expected, counted. |
| `sale_line` (changed) | + `day_old` boolean, + `full_price_cents` nullable | |

Audit (new actions): `stock.production_entered`, `stock.waste_recorded`, `stock.transfer_sent`, `stock.transfer_received`, `stock.transfer_mismatch`, `stock.count_adjusted`, `stock.ledger_mismatch`, `catalog.cost_changed`.

## 4. Flows

### 4.1 Production
The Producción section shows products as large buttons. Tap a product, tap a quantity: the numbers on screen are the product's usual amounts, in trays when the variant has `unitsPerTray`. That is the 2 taps. A `stock.produced` record goes out with the local date as `producedOn`. A wrong entry is fixed with waste or a count, never by editing.

### 4.2 Sales and oldest first
`sale.completed` lines gain `dayOld`. On sync the handler walks the branch's open lots oldest first, writes one `SALE` event per lot touched, and lowers `quantity_left`, under a lock per variant and branch. With `dayOld`, only lots that were aged at the sale's local date count. Units with no lot left write an event with no lot. See `stock-fifo-cases.json`.

### 4.3 Stock on the till
`GET /v1/stock/lots` returns the branch's open lots with their production dates. The till works out fresh and day-old itself, so ageing at midnight needs no connection. The sync worker pulls it each cycle. Offline, the till lowers its copy as it sells and adds its own production, then takes the server's lots on the next pull and applies what is still in its outbox.

### 4.4 Waste list
Each morning the manager's Inventario on the till lists lots at or past `dayOldWasteAfterDays`. Confirm writes waste with reason `EXPIRED`; a lot can be skipped, and it stays on the list.

### 4.5 Transfers
Send: pick the other branch, products and units. Receive: the other branch sees it as pending and enters what arrived. These two need the server, so they are online-only in this milestone; the till says so when offline.

### 4.6 Counts
A manager opens a count, enters units per variant, and confirms. Differences are applied to the oldest lots when lowering, and to a new lot dated today when raising.

## 5. Screens

Till: **Producción** (buttons, today's entries). **Ventas** gains the day-old button with its price and a warning when stock looks out. **Inventario** for managers (stock by age, waste list, count, transfers).

Back office: **Inventario** (stock by branch, ledger for a product, transfers, last nightly check), **Merma** (waste by date, product, reason and cost). Product form gains cost and units per tray.

## 6. Acceptance

| ID | Test | Trace |
| --- | --- | --- |
| F1 | A baker records a production in 2 taps (widget test counts taps), and it creates one lot dated that local day, offline | M5.1 |
| F2 | The server and app reproduce every case in `stock-fifo-cases.json` | M5.2 |
| F3 | A sale takes the oldest lot; a day-old sale takes only aged lots; a sale past all stock goes through and on-hand goes negative | M5.2 |
| F4 | Two tills offline sell the same last units, reconnect, and every sale is kept with on-hand equal to the ledger | M5.2, M5.6 |
| F5 | Waste needs a reason, lowers stock, and appears in Merma with its cost, or a dash with none | M5.3 |
| F6 | A transfer of 10 received as 9 records both, adds 9, and flags the mismatch with an audit row | M5.4 |
| F7 | A count with a difference writes one adjustment per variant, with the difference and who | M5.5 |
| F8 | `UPDATE` or `DELETE` on `stock_event` fails for the app role | M5.6 |
| F9 | The nightly check passes on a clean ledger, and when a lot is altered directly it writes `stock.ledger_mismatch` and changes nothing | M5.6 |
| F10 | Ageing crosses midnight in the branch's time zone, including a daylight-saving date | M6.1 |
| F11 | The till shows two buttons, each with its own stock and price, only when day-old stock exists; the line stores `dayOld` and the full price | M6.2 |
| F12 | Lots at the waste age appear on the manager's list; confirming records waste, skipping keeps them | M6.3 |
| F13 | A refund marked "vuelve al inventario" returns units; one not marked changes nothing | M5.2 |
| F14 | Manual: on a real tablet a baker enters a morning's production, and a cashier sells it on another till | M5.1 |

## 7. Out of scope for M5

Ingredients, recipes and recipe costing (Phase 2), standing orders that reserve stock (Sprint 6), the owner's daily report (Sprint 7), oven board (Sprint 6), weighed products, offline transfers.

## 8. Open for Fernando

- Is "a sale is never blocked by stock" right, or should a till refuse past zero?
- What are the usual day-old rules: how many days until discounted, at what percent, and how many days until waste?
- Who types the cost per product, and is cost needed for the pilot?
- Are the waste reasons right (burnt, expired, damaged, unsold)?
