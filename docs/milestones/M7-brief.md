# Milestone 7: Reports, owner dashboard and oven service

Status: draft for Fernando, 8 Nov 2026 · Architect and builder: Claude · Plan: [Phase 1 Implementation Plan](https://claude.ai/code/artifact/f7a32ce4-8b1b-427f-89c0-bf6379cbcb5f) (modules M9 and M8) · Sprint 7

This milestone gives the owner the numbers. A dashboard shows the day against the same weekday last week, by hour, the last 14 days, the best sellers and what needs a look: a cash difference, waste, customers who owe. Reports group sales by day, hour, branch, till, cashier, product or tax rate, and show stock and customer balances. Every report exports to Excel and CSV for the accountant. The Christmas oven service is in section 4.

Everything in the M1 to M6 briefs still applies.

---

## 1. Decisions (each changeable)

- **The branch's own day and hour.** A sale at 23:30 in Mexico City is that day's, whatever the server's clock says.
- **Reports agree with the Z report.** Sales count on the day they happened and refunds on the day they happened, on the till that paid them, exactly as the Z report counts them. So the day's report and the day's Z reports add up to the same centavo (M9.1).
- **Net means sales minus refunds** on the dashboard and in the "Neto menos devoluciones" column. Tax by rate is net of refunds.
- **A pickup is a sale.** Order pickups are sales paid from a balance. Reports split each total into cash and "pagado con saldo", so the cash column matches the drawers.
- **Who sees what.** The owner (`reports.all`) sees every branch, and a manager sees their own branches (`reports.branch`). A report covers at most 400 days.
- **Exports.** Excel (.xlsx) and CSV, in Spanish, with amounts in pesos as numbers the spreadsheet can add up. CSV carries a BOM so Excel shows the accents, and cells that start with `= + - @` are made safe. The Excel file is written by our own small writer, so the server gains no new dependency.
- **The dashboard compares with the same weekday last week.** A bakery's Monday is not its Saturday.

## 2. Screens

Back office **Reportes**, with tabs for the summary dashboard, sales, stock and customer balances. A date range and a branch filter apply to all tabs, and each report tab has Excel and CSV buttons.

## 3. Acceptance

| ID | Test | Trace |
| --- | --- | --- |
| H1 | A day's sales report matches the Z report of its shift: net, refunds and sale count, to the centavo | M9.1 |
| H2 | Sales group by hour and product, and tax by rate adds up to sales minus refunds | M9.1 |
| H3 | The stock report shows produced, sold, day-old sold, waste with cost and on hand at the end | M9.2 |
| H4 | The orders report shows tickets by day and status and every customer balance, lowest first | M9.3 |
| H5 | Every report exports to CSV and to an Excel file that opens, with a total row | M9.4 |
| H6 | The dashboard shows the day against the same weekday last week, by hour and by product | M9 |
| H7 | A manager asking for another branch gets 403; a range over 400 days gets 400 | M9 |

## 4. Oven service (M8)

At Christmas, customers bring their own dish (a turkey, a leg of pork) to bake in the bakery's oven. Fernando decided on 8 Nov 2026 that the fee depends on the dish type and the weight.

### 4.1 Decisions (each changeable)

- **Fee = base + price per kilo × weight.** Each dish type (Pavo, Pierna, Lechón) has its own base and price per kilo, set in back office Horno. Pavo at $80.00 + $40.00/kg costs $120.00 for 1 kg and $208.00 for 3.2 kg. Rounding is half up to the centavo, the same on the till and the server.
- **The fee is a sale.** Each dish type is a hidden service product with its own IVA rate. Its sale has a folio, a receipt, tax by rate, shift cash and the Z report like any sale, and it takes no stock. The customer pays once, either at drop-off or at pickup.
- **Each branch turns the service on or off.** It starts off. A till of a branch without the service refuses dishes, and so does the server.
- **The tag is the number on the claim slip** the customer keeps. The slip prints with the name, phone, dish, weight, requested time and whether the fee is paid.
- **Offline like a sale.** Drop-off, the bakers' steps and pickup are till records (`oven.received`, `oven.status`, `oven.picked_up`). A step never goes back; the furthest one stands. A dish picked up twice keeps the first pickup.
- **Who.** Cashiers and managers take and hand over dishes (`oven.intake_pickup`). Bakers and managers move them through the oven (`oven.board`). Owners and branch managers set the fees (`catalog.manage`). Turning a branch on or off needs `branches.manage`.

### 4.2 Screens

Till **Horno**: a *Mostrador* tab to receive a dish (tag, name, phone, dish and container, dish type, weight in kg, time wanted, pay now or later) and hand over the ready ones, charging when unpaid; and a *Horno* tab for the bakers with the queue by time wanted and the buttons *Al horno* and *Listo*. Back office **Horno**: the branches with the service and the dish types with their fees.

### 4.3 Acceptance

| ID | Test | Trace |
| --- | --- | --- |
| H8 | Pavo at $80.00 + $40.00/kg for 3.2 kg is $208.00 on the till and the server, and any other fee is refused | M8.1 |
| H9 | Paid at drop-off, the dish hands over without charging; unpaid, pickup charges it; a fee sale pays only one dish | M8.1, M8.3 |
| H10 | The fee appears on the receipt, tax by rate, shift cash and the Z report, and takes no stock | M8.1 |
| H11 | A step never goes back, and the counter sees a dish as ready once the baker marks it | M8.2 |
| H12 | A branch with the service off refuses dishes on the till and the server | M8.5 |
| H13 | Manual: on a tablet, receive, bake and hand over three dishes, one paid at drop-off | M8 |

## 5. Open for Fernando

- What else should the dashboard show first thing in the morning?
- Does the accountant want any report in a particular layout?
