# Milestone 3: Sales

Status: draft for Fernando, 1 Nov 2026 · Architect and builder: Claude · Plan: [Phase 1 Implementation Plan](https://claude.ai/code/artifact/f7a32ce4-8b1b-427f-89c0-bf6379cbcb5f) (modules M3 and M10) · Sprint 3

This milestone lets a cashier sell. The product grid from M2 becomes the sale screen. The cashier builds a ticket, applies a discount when allowed, takes cash and gives change. The till numbers the sale with its own gapless folio and shows the receipt on screen. A ticket can be held and resumed, and a paid sale can be refunded or voided with a manager's PIN. Every sale is written to the till's encrypted database and outbox in one transaction, and it reaches the server exactly once through the M2 sync engine, online or offline. The owner sees every sale in the back office.

Everything in the M1 and M2 briefs still applies. This brief only adds to it.

---

## 1. Who builds what

Fernando asked on 1 Nov 2026 for Claude to build the milestones itself for now, without prompts for the external developers. The split below still decides the branches and the PR size.

| Area | Scope |
| --- | --- |
| **Server** | Sale and refund tables, device till numbers and folio prefix, the `sale.completed` and `sale.refunded` sync handlers with totals validation, sale lookup for refunds, sale list and detail for the back office |
| **App** | Totals engine, cart and payment, discounts with approval, receipt on screen, folio counter, held tickets, refund and void flows, back office Ventas |
| **Contract** | `contracts/openapi.yaml` version `0.3.0-m3`, `contracts/fixtures/sale-totals-cases.json`, this brief |

Branches use the `m3/` prefix. Same rules as before: PRs under about 600 hand-written lines, 5 required checks green, and Fernando decides merges.

## 2. Decisions made for this milestone (each changeable)

- **Sales are created on the till, never on the server.** The server has no "create sale" endpoint. A sale exists once the till writes it; the server receives it as a `sale.completed` sync record whose `id` is the sale's ID. This is what makes selling identical online and offline.
- **Cash only** (M3 scope from 20 Oct). The `payment` table has a `method` column so card payments in Phase 2 need no schema change.
- **No open shift yet.** Cash shifts are Sprint 4. `sale.shift_id` is nullable in M3, and M4 makes an open shift required (M4.1).
- **Whole units only.** Quantities are integers. Products with unit `KG` are sold per whole unit until scale support in Phase 2.
- **Prices come from the till's catalog copy at the time of sale.** The cashier cannot type a price. The server validates the arithmetic and the tax rates, not the price against today's catalog, because the catalog may have changed while the till was offline.
- **Folios.** Each sales till gets a till number per branch, assigned when the device is created (1, 2, 3 …, never reused). The folio is `<branch code>-<till number, 2 digits>-<sale number, 6 digits>`, for example `SUC1-02-000153`. The counter lives in the till's encrypted database and moves in the same transaction as the sale, so numbers have no gaps. A ticket discarded before payment never takes a number. The server rejects a folio whose prefix is not the device's, and a folio number the device already used.
- **Discounts.** A discount applies to one line or to the whole ticket, as a percentage (bp) or an amount (cents), with a reason. Cashiers can give up to **10%** (`discountLimitBp = 1000`, sent to the till in the staff bundle). Anything above needs a manager's PIN (`sale.discount_over_limit`, M1 matrix). A ticket discount is spread over its lines in proportion to their amounts so tax stays correct per line (section 4.2).
- **Void after payment and refund are two actions.** *Cancelar venta* (`sale.void_after_payment`) reverses a whole sale on the same till on the same day. *Devolución* (`sale.refund`) returns all or some units of any sale in the branch. Both need a manager's PIN when a cashier does them (M1 matrix). Both are recorded as a `refund` row with `kind` `VOID` or `REFUND`.
- **Returning stock.** A refund line can be marked "vuelve al inventario". The flag is stored now and used when stock arrives in Sprint 5.
- **Held tickets stay on the till.** They are not synced. Any cashier logged in on the same till sees them. They keep the prices they had when held.
- **Receipt on screen only.** Printing is Sprint 4 (M11.2). The receipt screen shows exactly what the printed ticket will show.
- **Stock warning (M3.7) moves to Sprint 5,** where stock exists. Without stock there is nothing to warn about.

## 3. Data model (server)

All money is integer centavos with tax included. All tables have `created_at`.

| Table | Key columns | Notes |
| --- | --- | --- |
| `device` (changed) | + `till_number` int, nullable | Set for `TILL` devices on create: 1 + the highest till number ever used in that branch. Unique per branch. The migration numbers existing tills by `created_at`. |
| `sale` | id (from the till), device_id, branch_id, folio (unique), folio_number, cashier_staff_id, shift_id (nullable), occurred_at, received_at, gross_cents, discount_cents, total_cents, status (`COMPLETED`, `PARTIALLY_REFUNDED`, `REFUNDED`, `VOIDED`) | Unique (device_id, folio_number). Status changes only through refunds. |
| `sale_line` | sale_id, line_no, variant_id, product_name, variant_name, quantity, unit_price_cents, gross_cents, line_discount_cents, order_discount_cents, net_cents, iva_rate_id, iva_bp, ieps_rate_id (nullable), ieps_bp, base_cents, ieps_cents, iva_cents | Names are copied so old receipts read the same after a rename. Primary key (sale_id, line_no). |
| `sale_discount` | id, sale_id, line_no (null for the whole ticket), kind (`PERCENT`, `AMOUNT`), value, cents, reason, approver_staff_id (nullable) | `value` is bp for `PERCENT` and cents for `AMOUNT`; `cents` is what it took off. |
| `sale_voided_line` | sale_id, seq, variant_id, quantity, unit_price_cents, voided_at, staff_id | Lines removed from the ticket before payment, for the audit trail (M11.1). |
| `payment` | id, sale_id, method (`CASH`), amount_cents, tendered_cents, change_cents | `amount_cents` = what the sale cost; `tendered − change = amount`. |
| `refund` | id (from the till), sale_id, kind (`REFUND`, `VOID`), device_id, staff_id, approver_staff_id (nullable), reason, occurred_at, total_cents | |
| `refund_line` | refund_id, line_no, quantity, amount_cents, base_cents, ieps_cents, iva_cents, restock | `line_no` points at the sale line. |

Audit (`audit_log`, new actions): `sale.discount_over_limit` (one per approved discount above the limit), `sale.refunded`, `sale.voided`, `sale.ticket_discarded`. Each has actor, approver when there is one, `entity_type` `sale` and `entity_id` the sale ID (`sale.ticket_discarded` has no sale ID and stores the line count and amount).

## 4. Behaviour

### 4.1 Selling on the till
- The till home for cashiers and managers is the sale screen: the M2 product grid on the left, the ticket on the right (approved wireframe). Tapping a tile adds one unit; tapping again adds another. The ticket shows each line with quantity, price and line total, and the total in large type.
- Removing a line or lowering a quantity is allowed (`sale.void_line_before_payment`, all selling roles). Each removal is kept in the sale's `voidedLines`.
- **Cobrar** opens the payment panel with the total, an amount field and quick buttons: **Exacto**, $20, $50, $100, $200, $500. **Exacto** fills the exact total; a bill button fills that amount; the cashier can also type any amount. The change is shown in large type. **Finalizar** is enabled once the amount covers the total.
- A 3-item sale with exact cash takes 3 taps after the items are added: Cobrar, Exacto, Finalizar (M3.1).
- **Finalizar** runs one local transaction: take the next folio number, write the sale with its lines, discounts, voided lines and payment, and write the `sale.completed` outbox record. Then it shows the receipt. **Nueva venta** returns to an empty ticket.
- The receipt shows the branch name, folio, date and time, cashier, each line, discounts, total, "IVA incluido" with the tax by rate (base, IEPS, IVA), amount received and change.
- Leaving a ticket with lines without paying asks for confirmation and writes a `sale.ticket_discarded` offline audit event with the line count and amount.

### 4.2 Totals (same on server and app)
All values are integer centavos; `round` is half up. Put this in one pure function on each side and test it against `contracts/fixtures/sale-totals-cases.json`.
1. For each line: `gross = unitPrice × quantity`.
2. Line discount: `PERCENT` → `round(gross × bp / 10000)`; `AMOUNT` → the amount, which must not exceed `gross`. `afterLine = gross − lineDiscount`.
3. Ticket discount, on `sum(afterLine)`: `PERCENT` → `round(sum × bp / 10000)`; `AMOUNT` → the amount, not above `sum`.
4. Spread the ticket discount: each line gets `floor(ticketDiscount × afterLine / sum)`; the centavos left over go one each to the lines with the largest remainders (ties to the lower line number). `orderDiscount` per line is that share.
5. `net = afterLine − orderDiscount`. Split `net` with the M2 tax split (`splitTax(net, ivaBp, iepsBp)`) into base, IEPS and IVA.
6. Sale totals: `gross = Σ gross`, `discount = Σ (lineDiscount + orderDiscount)`, `total = Σ net`. Tax by rate is the sum of each line's parts grouped by rate.
7. Discount limit: a line discount's share is `lineDiscount / gross`; the ticket discount's share is `ticketDiscount / sum(afterLine)`. A share above `discountLimitBp / 10000` needs `approverStaffId`.

### 4.3 Refunds and voids
- **Devolución:** from the sale screen menu, the cashier enters or scans a folio. Online, the till looks it up with `GET /v1/sales/lookup?folio=…` (sales of this branch). Offline, only sales made on this till can be found. The cashier picks units per line (at most what is left), a reason and whether each line goes back to stock, then a manager approves with their PIN (cashiers only).
- **Cancelar venta:** the same flow with every unit selected, allowed only for a sale made on this till today.
- Refund amount per line, so partial refunds add up exactly to the line: with line net `N`, quantity `q`, units already refunded `r` and units now `k`, the amount is `round(N × (r + k) / q) − round(N × r / q)`. The tax parts are the tax split of that amount.
- The refund is written with its outbox record (`sale.refunded`) in one local transaction. The cashier sees "Entregar $X al cliente".

### 4.4 Held tickets
- **Guardar** keeps the current ticket (lines, discounts, an optional name such as "Señora del rebozo") in a local table and clears the screen. **En espera (n)** lists held tickets on this till with name, time, line count and total, newest first. Opening one restores it as the current ticket and removes it from the list. A held ticket can also be discarded, which writes `sale.ticket_discarded`.
- Held tickets survive an app restart and a change of cashier (M3.4). They are not synced and take no folio until paid.

### 4.5 On the server
- `sale.completed` handler: validate the payload with `SaleCompletedPayload`; the device must be a `TILL` in the branch; the cashier must belong to the branch and hold `sale.create`; folio prefix and number as in section 2; each variant must exist; each `ivaRateId`/`iepsRateId` must exist with the `bp` given; recompute every total with section 4.2 and reject any difference; check payments (`tendered ≥ total`, `change = tendered − total`); check each approver holds `sale.discount_over_limit` and every discount over the limit has one. Write the sale, its rows and the audit rows in the record's transaction. Any failure is `SYNC_INVALID_PAYLOAD` (shape) or `SYNC_REJECTED` (rules), with the reason in the message.
- `sale.refunded` handler: the sale must exist in the device's branch; units per line must not exceed what is left; amounts must match section 4.3; `VOID` must cover every remaining unit and come from the same device on the same local day (branch time zone); the staff member must hold `sale.refund` (or `sale.void_after_payment`), or have an approver who does. Update the sale status and write the audit row.
- A refund record can only arrive after its sale on the same till, because the outbox sends oldest first. A refund made on another till always comes from an online lookup, so its sale is already on the server.

## 5. Screens

Till (cashier and manager): the sale screen, payment panel, receipt, held tickets list, Devolución and Cancelar venta flows, discount dialog (line or ticket, % or $, reason list: Cliente frecuente, Producto dañado, Promoción, Otro with a note). Follow the approved wireframes ([design](https://claude.ai/artifact/PMKvvJ6PdGV57koaPLyv4J)). 56 dp touch targets; all text in `app_es.arb`.

Back office: **Ventas** (owner, and managers for their branches with `reports.branch`): list by date range, branch and folio, with totals; sale detail with lines, discounts, tax by rate, payment, voided lines and refunds. Devices list shows each till's folio prefix.

## 6. Acceptance tests

Each must exist as an automated test named with its ID unless marked manual.

| # | Test | Maps to |
| --- | --- | --- |
| D1 | A 3-item sale paid with exact cash takes exactly 3 taps after adding the items (widget test counts taps) and shows the receipt with folio, total and change $0.00 | M3.1 |
| D2 | One sale writes the sale, its lines, its payment, the next folio and one `sale.completed` outbox record in a single local transaction; a failure in any part leaves none of them | M3.2 |
| D3 | Totals: app and server reproduce every row of `contracts/fixtures/sale-totals-cases.json` (line and ticket discounts, spreading, tax by rate) | M3.2, M3.3 |
| D4 | A sale with a 10% line discount and a $5.00 ticket discount charges the reduced total; the receipt, the server's sale and the back office show both discounts | M3.3 |
| D5 | A cashier's 15% discount asks for a manager's PIN; without it the discount is refused. On the server, a record with a discount over the limit and no approver is quarantined with `SYNC_REJECTED` | M3.3 |
| D6 | A held ticket survives closing and reopening the database, is visible after another cashier logs in on the same till, and resumes with the same lines and discounts | M3.4 |
| D7 | Partial refund of 1 of 3 units with a manager's PIN, online and offline, returns the right amount; refunding more than is left is refused on the till and quarantined on the server; refunding the rest marks the sale `REFUNDED` | M3.5 |
| D8 | Cancelar venta needs a manager's PIN for a cashier, is refused for another till's sale or a past day, and marks the sale `VOIDED` | M3.5 |
| D9 | 1,000 sales on one till get folios 000001 to 001000 with no gaps; discarded and held tickets take no number; the server rejects a repeated folio number and a folio with another till's prefix | M3.6 |
| D10 | Two tills sell 200 sales each while offline, reconnect, and the server holds exactly 400 sales with no duplicates (server end-to-end test with two device tokens, pushing each batch twice) | M10.1, M10.2 |
| D11 | Back office: the owner lists sales by date and branch and opens one with its lines, discounts, tax by rate, payment and refunds; a manager sees only their branches; a cashier gets 403 | M3.2 |
| D12 | Manual: on a real tablet, a cashier rings up 20 sales in a row with the internet off, then turns it on, and all 20 reach the server within 2 minutes | M10.1 |

## 7. Out of scope for M3

Cash shifts and Z report (Sprint 4), printing and the cash drawer (Sprint 4), stock and the stock warning (Sprint 5), day-old prices (Sprint 5), customers and standing orders (Sprint 6), card payments and CFDI (Phase 2), weighed sales with a scale, price overrides at the till, tips.

## 8. Open for Fernando

- Is 10% the right limit for a cashier's discount without a manager?
- Are $20, $50, $100, $200 and $500 the right quick bill buttons?
- Folio format `SUC1-02-000153`: keep, or shorter?
