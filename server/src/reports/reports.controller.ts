import { Controller, Get, Query, Res } from '@nestjs/common';
import type { Response } from 'express';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import {
  DashboardQueryDto,
  RangeExportQueryDto,
  RangeQueryDto,
  SalesExportQueryDto,
  SalesReportQueryDto,
} from './dto/reports.dto';
import { balancesTable, salesTable, stockTable } from './reports-export';
import { ReportsService } from './reports.service';
import { Cell, csv, xlsx } from './xlsx';

const TYPES = {
  csv: 'text/csv; charset=utf-8',
  xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
};

function send(
  res: Response,
  format: 'csv' | 'xlsx',
  name: string,
  table: { header: string[]; rows: Cell[][] },
) {
  const body =
    format === 'csv'
      ? csv(table.header, table.rows)
      : xlsx(name, table.header, table.rows);
  res
    .status(200)
    .setHeader('Content-Type', TYPES[format])
    .setHeader(
      'Content-Disposition',
      `attachment; filename="${name}.${format}"`,
    )
    .send(body);
}

@Controller('reports')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}

  @Get('dashboard')
  @RequirePermission('reports.branch')
  dashboard(
    @Query() q: DashboardQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.reports.dashboard(user, q);
  }

  @Get('sales')
  @RequirePermission('reports.branch')
  sales(
    @Query() q: SalesReportQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.reports.sales(user, q);
  }

  @Get('sales/export')
  @RequirePermission('reports.branch')
  async salesExport(
    @Query() q: SalesExportQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() res: Response,
  ) {
    const r = await this.reports.sales(user, q);
    send(res, q.format, `ventas-${q.groupBy}-${q.from}-${q.to}`, salesTable(r));
  }

  @Get('stock')
  @RequirePermission('reports.branch')
  stock(@Query() q: RangeQueryDto, @CurrentUser() user: AuthenticatedUser) {
    return this.reports.stock(user, q);
  }

  @Get('stock/export')
  @RequirePermission('reports.branch')
  async stockExport(
    @Query() q: RangeExportQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() res: Response,
  ) {
    const r = await this.reports.stock(user, q);
    send(res, q.format, `inventario-${q.from}-${q.to}`, stockTable(r));
  }

  @Get('orders')
  @RequirePermission('reports.branch')
  orders(@Query() q: RangeQueryDto, @CurrentUser() user: AuthenticatedUser) {
    return this.reports.orders(user, q);
  }

  @Get('orders/export')
  @RequirePermission('reports.branch')
  async ordersExport(
    @Query() q: RangeExportQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() res: Response,
  ) {
    const r = await this.reports.orders(user, q);
    send(res, q.format, `saldos-${q.to}`, balancesTable(r));
  }
}
