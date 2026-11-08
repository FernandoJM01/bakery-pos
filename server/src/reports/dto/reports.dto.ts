import { IsIn, IsOptional, IsUUID, Matches } from 'class-validator';

const LOCAL_DATE = /^\d{4}-\d{2}-\d{2}$/;

export const SALES_GROUPS = [
  'day',
  'hour',
  'branch',
  'device',
  'cashier',
  'product',
  'taxRate',
] as const;
export type SalesGroup = (typeof SALES_GROUPS)[number];

export class RangeQueryDto {
  @Matches(LOCAL_DATE)
  from!: string;

  @Matches(LOCAL_DATE)
  to!: string;

  @IsOptional()
  @IsUUID()
  branchId?: string;
}

export class SalesReportQueryDto extends RangeQueryDto {
  @IsIn(SALES_GROUPS)
  groupBy!: SalesGroup;
}

export class ExportQueryDto {
  @IsIn(['csv', 'xlsx'])
  format!: 'csv' | 'xlsx';
}

export class SalesExportQueryDto extends SalesReportQueryDto {
  @IsIn(['csv', 'xlsx'])
  format!: 'csv' | 'xlsx';
}

export class RangeExportQueryDto extends RangeQueryDto {
  @IsIn(['csv', 'xlsx'])
  format!: 'csv' | 'xlsx';
}

export class DashboardQueryDto {
  @IsOptional()
  @Matches(LOCAL_DATE)
  date?: string;

  @IsOptional()
  @IsUUID()
  branchId?: string;
}

export class BranchQueryDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}
