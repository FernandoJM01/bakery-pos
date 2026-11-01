# Milestone 4: Cash shifts, audit and printing

Status: draft for Fernando, 1 Nov 2026 · Architect and builder: Claude · Plan: [Phase 1 Implementation Plan](https://claude.ai/code/artifact/f7a32ce4-8b1b-427f-89c0-bf6379cbcb5f) (modules M4 and M11) · Sprint 4

This milestone accounts for every peso. A till sells only inside an open shift, which starts with a counted float. Cash in and cash out are recorded with a reason. The cashier closes blind: they count the drawer by denomination before seeing what was expected. The till then shows expected, counted and the difference, and produces a Z report that matches the sales. Receipts and Z reports print on an 80 mm network printer, and without a printer the same documents show on screen. The owner sees every shift and every flagged difference in the back office, and can search the audit log.

Everything in the M1, M2 and M3 briefs still applies. This brief only adds to it.

---

## 1. Who builds what

Fernando asked on 1 Nov 2026 for Claude to build the milestones itself for now, without prompts for the external developers. The split below still decides the branches and the PR size.

| Area | Scope |
| --- | --- |
| **Server** | Shift, cash movement and count tables, the `shift.opened`, `cash.movement`, `shift.closed` sync handlers with recomputed totals, `shiftId` required on sales and refunds, shift list and detail for the back office, audit filters |
| **App** | Shift engine and cash totals, open shift, cash in and out, blind close, Z report, printing service, drawer kick, printer setting, back office Turnos |
| **Contract** | `contracts/openapi.yaml` version `0.4.0-m4`, `contracts/fixtures/shift-cash-cases.json`, this brief |

Branches use the `m4/` prefix. Same rules as before: PRs under about 600 hand-written lines and 5 required checks green.

## 2. Decisions made for this milestone (each changeable)

- **Shifts are created on the till, never on the server,** like sales, so opening, moving cash and closing work offline. The server receives them as sync records and checks every rule again.
- **One open shift per till.** The shift belongs to the till and its drawer, not to a person. If cashiers change during the day they log in and out inside the same shift. Whoever closes counts the drawer.
- **No sale, refund or void without an open shift (M4.1).** `shiftId` becomes required on `sale.completed` and `sale.refunded`. Nothing is in production yet, so no old records need a null.
- **A refund comes out of the drawer that pays it.** A refund uses the open shift of the till that gives the money back, even when the sale was made on another till or day.
- **Cashiers open and close; cash in and out need a manager.** This is the M1 matrix: cashiers hold `cash.open_shift` and `cash.close_shift` but not `cash.movement`, so a cashier's movement takes a manager's PIN. Opening the drawer without a sale works the same way (`cash.open_drawer_no_sale`) and leaves an audit row.
- **The float is counted, not carried over.** Each shift starts with what the opener counts, by denomination. A float different from the last shift's closing count shows a warning on the till and on the shift, but does not block.
- **Blind close.** The expected amount is never shown before the count is confirmed, on the till or in the payload order. Once confirmed the count cannot be changed; a correction is a note by a manager in the back office, and the original stays.
- **Denominations:** $1000, $500, $200, $100, $50, $20, $10, $5, $2, $1, $0.50. Bills and coins of the same value ($20) share one row.
- **Variance flag (M4.5):** a difference above **$50.00** in either direction is flagged (`cashVarianceFlagCents = 5000`, sent to the till in the staff bundle). The flag shows in Turnos and feeds the owner's daily report in Sprint 7. A note is required on the till when flagged.
- **Z numbers.** Each closed shift gets a Z number per till, `<folio prefix>-Z<4 digits>`, for example `SUC1-02-Z0012`, moved in one transaction like the folio.
- **Prepaid orders collected** appear on the Z report as a line at $0.00 until Sprint 6 brings orders. The report layout does not change later.
- **Printing is per till.** Each till stores its own printer (IP and port, default 9100) in the till settings. ESC/POS over a plain TCP socket, 80 mm, 48 columns. A failed print never blocks or undoes a sale; the document stays on screen with a retry button.
- **Drawer kick on cash sales.** The ESC/POS kick is sent with the receipt when the printer is set. Refunds open the drawer too, since they pay cash out.
- **Claim tickets and pick lists** are Sprint 6 (orders). This milestone builds the print layer they will use.

## 3. Data model (server)

All money is integer centavos.

| Table | Key columns | Notes |
| --- | --- | --- |
| `cash_shift` | id (from the till), device_id, branch_id, z_number (int, nullable until closed), status (`OPEN`, `CLOSED`), opened_at, opened_by_staff_id, float_cents, closed_at, closed_by_staff_id, expected_cents, counted_cents, variance_cents, flagged, note | At most one `OPEN` per device (partial unique index). Unique (device_id, z_number). |
| `cash_movement` | id (from the till), shift_id, kind (`IN`, `OUT`), amount_cents, reason, note, staff_id, approver_staff_id, occurred_at | `amount_cents` > 0. |
| `cash_count` | shift_id, stage (`OPEN`, `CLOSE`), denomination_cents, quantity | Primary key (shift_id, stage, denomination_cents). |
| `sale` (changed) | `shift_id` now required on new records, FK to `cash_shift` | |
| `refund` (changed) | + `shift_id`, FK to `cash_shift` | The till that paid the money. |

Audit (`audit_log`, new actions): `cash.shift_opened`, `cash.movement`, `cash.shift_closed`, `cash.variance_flagged`, `cash.drawer_opened`, `cash.note_added`.

Till (drift): `local_shifts`, `local_cash_movements`, `local_cash_counts`. A sale or refund finds its shift in the same transaction that writes it.

## 4. Flows

### 4.1 Opening
The Caja section shows the state. With no open shift, the sale screen shows "Abre un turno para vender" with a button. The cashier counts the float by denomination; the total adds up as they type. **Abrir turno** writes the shift, its count and the `shift.opened` outbox record in one local transaction.

### 4.2 Cash in and out
From Caja: **Entrada** or **Salida**, amount, reason (`CHANGE_FUND`, `SUPPLIER_PAYMENT`, `BANK_DROP`, `OTHER`, a note when `OTHER`), manager PIN for cashiers. A `cash.movement` record goes out in the same local transaction. The till never refuses a cash-out for being above what the drawer should hold, because that would reveal the expected amount.

### 4.3 Expected cash (same on server and app)
All values are integer centavos. Put this in one pure function on each side and test it against `contracts/fixtures/shift-cash-cases.json`.

```
expected = float
         + Σ sale payments in this shift (amountCents)
         + Σ cash movements IN
         − Σ cash movements OUT
         − Σ refunds in this shift (totalCents)
variance = counted − expected
flagged  = |variance| > cashVarianceFlagCents
```

Change given is already out of `amountCents`, since a sale's amount is the total and not what the customer handed over.

### 4.4 Blind close
From Caja, **Cerrar turno** first asks to hold or finish any open ticket; held tickets stay on the till and survive into the next shift. Then the cashier counts by denomination, with no expected amount on screen. **Confirmar conteo** is final. In one local transaction the till takes the next Z number, computes expected, stores the count, closes the shift and writes the `shift.closed` record. Then it shows expected, counted and the difference. A flagged difference requires a note before the Z report appears.

### 4.5 Z report
Shows branch, till, Z number, who opened and closed and when; sales count; gross, discounts and net; sales by tax rate (base, IEPS, IVA); refunds and voids; prepaid orders collected; cash in and out by reason; float, expected, counted and difference. It prints when a printer is set and is always viewable later, on the till for shifts it holds and in the back office for all. Tax by rate uses net sales minus refunds, from stored line and refund amounts, never recomputed from prices.

### 4.6 On the server
- `shift.opened`: device is a `TILL`; the staff member belongs to the branch and holds `cash.open_shift`; no other `OPEN` shift on the device; the count adds up to `floatCents`.
- `cash.movement`: the shift exists on this device and is open at `occurredAt`; the staff member holds `cash.movement`, or a valid approver does.
- `sale.completed` and `sale.refunded`: `shiftId` must be a shift of this device. A sale or refund with `occurredAt` after the shift's `closedAt` is rejected.
- `shift.closed`: the shift is open on this device; the staff member holds `cash.close_shift`; the Z number is the next for the device; the count adds up to `countedCents`; the server recomputes expected, variance and the flag and rejects a difference. Records arrive oldest first, so all the shift's sales are in before the close.
- Rejections use `SYNC_INVALID_PAYLOAD` (shape) or `SYNC_REJECTED` (rules), go to quarantine, and never block other records.

## 5. Screens

Till: **Caja** (state, float, totals so far with no expected amount, Entrada, Salida, Abrir cajón, Cerrar turno, past Z reports). Till settings: **Impresora** (IP, port, test print). Sale screen: banner with no open shift; automatic print and drawer kick after payment; **Reimprimir** on the receipt.

Back office: **Turnos** (owner, and managers for their branches with `reports.branch`): list by date, branch and till with expected, counted, difference and a flag, filter "solo diferencias"; shift detail with counts, movements and Z report; a note can be added. **Auditoría** gains filters by action, person, branch and date, and shows the new actions (M11.1).

## 6. Acceptance

| ID | Test | Trace |
| --- | --- | --- |
| E1 | With no open shift the sale screen cannot charge, and the server rejects a sale or refund with no `shiftId` | M4.1 |
| E2 | Opening writes the shift, its count and one outbox record in a single local transaction; a failure leaves none; a second open on the same till is refused on both sides | M4.1 |
| E3 | The server and app reproduce every case in `shift-cash-cases.json` | M4.3 |
| E4 | Each movement records amount, reason, user and approver; a cashier without a manager's PIN is refused on till and server | M4.2 |
| E5 | During a blind close no screen or widget shows the expected amount before the count is confirmed (widget test) | M4.3 |
| E6 | A confirmed count cannot change; the server rejects a second `shift.closed` and any expected, variance or flag that differs from its own | M4.3 |
| E7 | A difference of $50.00 is not flagged and $50.01 is, in both directions, and needs a note on the till | M4.5 |
| E8 | A day of 200 sales with discounts, refunds, a void, cash in and out gives a Z report whose every line matches the sum of the stored sales, to the centavo, on till and server | M4.4 |
| E9 | A refund on another till takes the money from that till's shift; both shifts balance | M4.3 |
| E10 | Two tills work offline through a shift and close it, reconnect, and the server holds both shifts with no duplicates, pushing each batch twice | M10.1 |
| E11 | Against a fake ESC/POS socket, a sale sends the receipt and the drawer kick; a dead printer leaves the sale paid, the document on screen and a retry button | M11.2 |
| E12 | The new actions write one audit row each with the right actor and approver; `UPDATE` or `DELETE` still fails; the owner filters by action, person, branch and date; a manager sees only their branches | M11.1 |
| E13 | Back office: the owner lists shifts, filters to differences and opens a Z report; a cashier gets 403 | M4.4 |
| E14 | Manual: on a real tablet with a real 80 mm printer and drawer, a full shift is opened, sold through, closed and its Z report printed | M11.2 |

## 7. Out of scope for M4

Stock and adjustments in the audit log (Sprint 5), claim tickets, pick lists and prepaid orders (Sprint 6), the owner's daily report (Sprint 7), card payments and CFDI (Phase 2), USB or Bluetooth printers, tips, safe management.

## 8. Open for Fernando

- Which printer and cash drawer will the branches use? E14 needs one, and it must have a network port.
- Is $50.00 the right difference to flag?
- Are the cash-out reasons right (change fund, supplier payment, bank drop, other)?
- Should a shift belong to the till (as written) or to one cashier at a time?
