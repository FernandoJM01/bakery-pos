import { Cell } from './xlsx';
import type { ReportsService } from './reports.service';

type Sales = Awaited<ReturnType<ReportsService['sales']>>;
type Stock = Awaited<ReturnType<ReportsService['stock']>>;
type Orders = Awaited<ReturnType<ReportsService['orders']>>;

/** Pesos with two decimals, as a number the spreadsheet can add up. */
const pesos = (cents: number | null) =>
  cents == null ? null : Math.round(cents) / 100;

const GROUP_HEADER: Record<string, string> = {
  day: 'Día',
  hour: 'Hora',
  branch: 'Sucursal',
  device: 'Caja',
  cashier: 'Cajero',
  product: 'Producto',
  taxRate: 'Impuesto',
};

/** The accountant's tables (M9.4), in Spanish like everything they read. */
export function salesTable(r: Sales): { header: string[]; rows: Cell[][] } {
  const tax = r.groupBy === 'taxRate';
  const header = tax
    ? ['Impuesto', 'Base', 'Impuesto cobrado', 'Ventas', 'Devoluciones']
    : [
        GROUP_HEADER[r.groupBy],
        'Ventas',
        ...(r.groupBy === 'product' ? ['Piezas'] : []),
        'Bruto',
        'Descuentos',
        'Neto',
        'Efectivo',
        'Pagado con saldo',
        'Devoluciones',
        'Neto menos devoluciones',
      ];
  const line = (x: Sales['items'][number]): Cell[] =>
    tax
      ? [
          x.label,
          pesos(x.baseCents),
          pesos(x.taxCents),
          pesos(x.netCents),
          pesos(x.refundCents),
        ]
      : [
          x.label,
          x.saleCount,
          ...(r.groupBy === 'product' ? [x.quantity] : []),
          pesos(x.grossCents),
          pesos(x.discountCents),
          pesos(x.netCents),
          pesos(x.cashCents),
          pesos(x.prepaidCents),
          pesos(x.refundCents),
          pesos(x.netCents - x.refundCents),
        ];
  return { header, rows: [...r.items.map(line), line(r.totals)] };
}

export function stockTable(r: Stock): { header: string[]; rows: Cell[][] } {
  return {
    header: [
      'Sucursal',
      'Producto',
      'Variante',
      'Producido',
      'Vendido',
      'Vendido día anterior',
      'Devuelto',
      'Merma',
      'Costo de merma',
      'Recibido',
      'Enviado',
      'Ajuste por conteo',
      'Existencia al cierre',
    ],
    rows: r.items.map((x) => [
      x.branchName,
      x.productName,
      x.variantName,
      x.produced,
      x.sold,
      x.dayOldSold,
      x.returned,
      x.wasted,
      pesos(x.wasteCostCents),
      x.transferredIn,
      x.transferredOut,
      x.adjusted,
      x.onHand,
    ]),
  };
}

export function balancesTable(r: Orders): { header: string[]; rows: Cell[][] } {
  return {
    header: ['Cliente', 'Teléfono', 'Saldo'],
    rows: r.balances.map((b) => [b.name, b.phone, pesos(b.balanceCents)]),
  };
}
