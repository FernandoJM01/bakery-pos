# Milestone 6: Customers, standing orders and pre-orders

Status: draft for Fernando, 8 Nov 2026 · Architect and builder: Claude · Plan: [Phase 1 Implementation Plan](https://claude.ai/code/artifact/f7a32ce4-8b1b-427f-89c0-bf6379cbcb5f) (module M7) · Sprint 6

This milestone handles the orders Fernando called very important: a customer who takes 30 bolillos Monday to Friday at 07:30 and pays ahead. The counter records the customer and the order, and takes the prepayment through the till like any cash. Each morning the baker sees how much the orders need, and the counter sees who comes at what time. A pickup is one tap and works offline: it hands over the bread, takes it from stock and from the customer's balance. A missed pickup is still charged unless the order says otherwise. A cake for Saturday with a deposit uses the same flow.

Everything in the M1 to M5 briefs still applies. This brief only adds to it.

---

## 1. Who builds what

Fernando asked on 1 Nov 2026 for Claude to build the milestones itself for now. Branches use the `m6/` prefix.

| Area | Scope |
| --- | --- |
| **Server** | Customers, orders and their schedule, daily order tickets, the prepaid balance ledger, prepayment and pickup sync handlers, missed pickups, pick list, order feed for tills |
| **App** | Customer search and form, order form, prepayment, pickup list and pickup, pick list for the baker, back office Pedidos |
| **Contract** | `contracts/openapi.yaml` version `0.6.0-m6`, `contracts/fixtures/order-schedule-cases.json`, this brief |

## 2. Decisions made for this milestone (each changeable)

- **One kind of order, two shapes.** A *standing order* repeats on chosen weekdays between a start date and an optional end date. A *pre-order* is the same order with one date. Both have lines (variant, quantity), a branch, a pickup time and a missed-pickup rule.
- **Orders and customers are written online; pickups and payments work offline.** Taking an order is planned, not rushed, and it needs the server to check the schedule and balance. Paying and picking up happen at 07:30 with a queue, so they are till records like sales.
- **Each day an order is due becomes an order ticket.** The server keeps tickets for today and the next 2 days, made nightly and again whenever an order changes. A ticket holds a copy of the lines with the price and tax rates of the day it was made, so the till can hand it over offline and the amount never changes under the customer.
- **The balance belongs to the customer.** Prepayments add to it, pickups and charged misses take from it. It is a ledger like stock: `prepaid_entry` rows that are only inserted, and the balance is their sum.
- **A prepayment is cash in the drawer.** It goes through the open shift as `order.prepaid` and counts in expected cash. This fills the "anticipos cobrados" line of the Z report that M4 left at $0.00. The expected-cash formula becomes `float + cash sales + prepayments + cash in − cash out − refunds`.
- **A pickup is a sale paid from the balance.** The till writes a normal `sale.completed` with payment method `PREPAID` and the ticket id. So stock, tax by rate, folio, receipt and refunds all work as for any sale, and the server checks the lines and amount against the ticket. A `PREPAID` sale puts no cash in the drawer.
- **The balance can go negative.** The bread is handed over either way. A pickup that leaves the balance below the next ticket's amount shows "saldo bajo" on the till and the receipt.
- **Missed pickups.** At 03:00 the server marks yesterday's pending tickets as missed. With the rule `CHARGE`, which is the default, the amount is taken from the balance. With `NO_CHARGE`, nothing is. A missed ticket does not touch stock or tax, because nothing was handed over.
- **Changes and pauses.** Skipping a date, pausing between two dates and changing lines rebuild the tickets not yet picked up. Picked-up and missed tickets never change.
- **Claim ticket.** A prepayment prints a slip with the order, the dates covered and the new balance, on the M4 printing layer. Without a printer it shows on screen.
- **No RFC validation.** The RFC is stored as typed for the accountant. CFDI is Phase 2.

## 3. Data model (server)

| Table | Key columns | Notes |
| --- | --- | --- |
| `customer` | id, name, phone, rfc (nullable), notes, is_active | Phone unique when given. Searchable by name or phone. |
| `customer_order` | id, customer_id, branch_id, kind (`STANDING`, `ONE_OFF`), weekdays (int bit set, Monday = 1), start_date, end_date (nullable), pickup_time, missed_rule (`CHARGE`, `NO_CHARGE`), status (`ACTIVE`, `PAUSED`, `ENDED`), paused_from, paused_until, created_by | A one-off order has `start_date = end_date` and no weekdays. |
| `customer_order_line` | order_id, variant_id, quantity | |
| `order_skip` | order_id, date | Dates the customer will not come. |
| `order_ticket` | id, order_id, branch_id, customer_id, due_date, pickup_time, status (`PENDING`, `PICKED_UP`, `MISSED`, `SKIPPED`), total_cents, sale_id (nullable) | Unique (order_id, due_date). With `order_ticket_line`: variant, names, quantity, unit price, tax rates, line amounts. |
| `prepaid_entry` | id, customer_id, kind (`PAYMENT`, `PICKUP`, `MISSED`, `ADJUSTMENT`), amount_cents (signed), ticket_id, shift_id, device_id, staff_id, occurred_at | Insert-only for `pos_app`. |
| `payment` (changed) | `method` gains `PREPAID` | |
| `sale` (changed) | + `order_ticket_id` nullable | |

Audit (new actions): `customer.created`, `customer.updated`, `order.created`, `order.updated`, `order.paused`, `order.skipped`, `order.prepaid`, `order.picked_up`, `order.missed`.

## 4. Flows

### 4.1 Schedule (same on server and app)
A date is due for an order when it is between the start and end dates, its weekday is in the order's weekdays (one-off: it is the start date), it is not skipped, and it is not inside a pause. Put this in one pure function on each side and test it against `contracts/fixtures/order-schedule-cases.json`.

### 4.2 Taking an order
Pedidos > Nuevo: search the customer by name or phone, or create one. Pick products and quantities, weekdays or a single date, pickup time, the missed rule, and optionally take a prepayment right away. The screen shows what one day costs and what the chosen period costs.

### 4.3 Prepayment
From the order or the customer: an amount, cash, in the open shift. The till writes `order.prepaid` and its outbox record in one transaction, opens the drawer and prints the claim ticket. The server adds a `PAYMENT` entry and an audit row.

### 4.4 Pickup
The till's Pedidos tab lists today's tickets for this branch by pickup time, with the customer, lines and balance. Entregar writes a `PREPAID` sale from the ticket in one tap, prints the receipt, and marks the ticket on the till. On sync the server checks that the ticket is pending, in the device's branch and due today or before, that the lines and amount match it, and then takes stock oldest first as for any sale, adds a `PICKUP` entry and marks the ticket picked up. A ticket picked up twice on two tills offline keeps the first; the second is quarantined.

### 4.5 Pick list
The baker's Producción shows today's totals per product from the tickets. The counter's Pedidos shows one row per customer and pickup time. Both come from the ticket feed and work offline.

### 4.6 On the server
- `order.prepaid`: customer exists, staff holds `orders.manage` or `orders.pickup`, shift checks as for a sale, amount > 0.
- `sale.completed` with `PREPAID`: everything in M3 4.5, plus the ticket rules in 4.4. No cash checks; tendered and change are 0.
- Expected cash counts only `CASH` payments, plus prepayments.

## 5. Screens

Till: **Pedidos** (today's tickets by time, Entregar, balance, prepayment, new order when online). **Producción** gains "Para pedidos de hoy". Back office: **Pedidos** (customers, orders, a customer's balance and history, skip, pause, change, end).

## 6. Acceptance

| ID | Test | Trace |
| --- | --- | --- |
| G1 | A customer is found by part of the name or the phone at the till | M7.1 |
| G2 | The server and app reproduce every case in `order-schedule-cases.json` | M7.2 |
| G3 | 30 bolillos Monday to Friday at 07:30 makes tickets only on those days, and a skipped date or a pause makes none | M7.2, M7.6 |
| G4 | A prepayment adds to the balance, counts in expected cash and appears as "anticipos" on the Z report | M7.3 |
| G5 | The baker's totals and the counter's list for a day match that day's tickets | M7.4 |
| G6 | A pickup offline takes stock oldest first, takes the amount from the balance and marks the ticket; the receipt shows the new balance | M7.5 |
| G7 | A pickup whose lines or amount differ from the ticket, or of a ticket already picked up, is quarantined | M7.5 |
| G8 | A missed ticket is charged with `CHARGE` and not with `NO_CHARGE`, and touches no stock | M7.5 |
| G9 | Changing quantities rebuilds only tickets not picked up; past tickets keep their amounts | M7.6 |
| G10 | A cake for Saturday with a deposit makes one ticket and picks up like any order | M7.7 |
| G11 | `UPDATE` or `DELETE` on `prepaid_entry` fails for the app role | M7.3 |
| G12 | Manual: a real customer's week of standing orders runs on a tablet, with one missed day | M7 |

## 7. Out of scope for M6

Delivery, online ordering by customers, card payments, messages to customers, discounts on orders, recurring billing by itself, CFDI.

## 8. Open for Fernando

- Is "missed pickups are still charged" right for every customer, or should the default be no charge?
- Should a customer be able to owe money (negative balance), or should the till refuse the pickup?
- Who takes orders: managers only, or cashiers too?
