import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

const MAX_CENTS = 100_000_000;

export const DISCOUNT_REASONS = [
  'FREQUENT_CUSTOMER',
  'DAMAGED',
  'PROMOTION',
  'OTHER',
] as const;

export const REFUND_REASONS = [
  'CUSTOMER_RETURN',
  'WRONG_ITEM',
  'QUALITY',
  'CASHIER_ERROR',
  'OTHER',
] as const;

/** `DiscountInput` */
export class DiscountInputDto {
  @IsIn(['PERCENT', 'AMOUNT'])
  kind!: 'PERCENT' | 'AMOUNT';

  @IsInt()
  @Min(1)
  @Max(MAX_CENTS)
  value!: number;

  @IsIn(DISCOUNT_REASONS)
  reason!: (typeof DISCOUNT_REASONS)[number];

  @IsOptional()
  @IsString()
  @MaxLength(120)
  note?: string | null;

  @IsOptional()
  @IsUUID()
  approverStaffId?: string | null;
}

function Cents(min = 0) {
  return (target: object, key: string) => {
    IsInt()(target, key);
    Min(min)(target, key);
    Max(MAX_CENTS)(target, key);
  };
}

function Bp() {
  return (target: object, key: string) => {
    IsInt()(target, key);
    Min(0)(target, key);
    Max(10000)(target, key);
  };
}

/** `SaleLineInput` */
export class SaleLineInputDto {
  @IsInt()
  @Min(1)
  @Max(500)
  lineNo!: number;

  @IsUUID()
  variantId!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  productName!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  variantName!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;

  @Cents(1)
  unitPriceCents!: number;

  @IsBoolean()
  dayOld!: boolean;

  @Cents(1)
  fullPriceCents!: number;

  @IsUUID()
  ivaRateId!: string;

  @Bp()
  ivaBp!: number;

  @IsOptional()
  @IsUUID()
  iepsRateId?: string | null;

  @Bp()
  iepsBp!: number;

  @IsOptional()
  @ValidateNested()
  @Type(() => DiscountInputDto)
  discount?: DiscountInputDto | null;

  @Cents() grossCents!: number;
  @Cents() lineDiscountCents!: number;
  @Cents() orderDiscountCents!: number;
  @Cents() netCents!: number;
  @Cents() baseCents!: number;
  @Cents() iepsCents!: number;
  @Cents() ivaCents!: number;
}

/** `VoidedLineInput` */
export class VoidedLineInputDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;

  @Cents(1)
  unitPriceCents!: number;

  @IsISO8601({ strict: true })
  voidedAt!: string;

  @IsUUID()
  staffId!: string;
}

/** `PaymentInput` */
export class PaymentInputDto {
  @IsIn(['CASH'])
  method!: 'CASH';

  @Cents() amountCents!: number;
  @Cents() tenderedCents!: number;
  @Cents() changeCents!: number;
}

/** `SaleCompletedPayload`; the record id is the sale id. */
export class SaleCompletedPayloadDto {
  @Matches(/^[A-Z0-9]{1,10}-[0-9]{2}-[0-9]{6}$/)
  folio!: string;

  @IsInt()
  @Min(1)
  @Max(999_999)
  folioNumber!: number;

  @IsUUID()
  cashierStaffId!: string;

  @IsUUID()
  shiftId!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(500)
  @ValidateNested({ each: true })
  @Type(() => SaleLineInputDto)
  lines!: SaleLineInputDto[];

  @IsOptional()
  @ValidateNested()
  @Type(() => DiscountInputDto)
  orderDiscount?: DiscountInputDto | null;

  @IsArray()
  @ArrayMaxSize(500)
  @ValidateNested({ each: true })
  @Type(() => VoidedLineInputDto)
  voidedLines!: VoidedLineInputDto[];

  @Cents() grossCents!: number;
  @Cents() discountCents!: number;
  @Cents() totalCents!: number;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(1)
  @ValidateNested({ each: true })
  @Type(() => PaymentInputDto)
  payments!: PaymentInputDto[];
}

/** `RefundLineInput` */
export class RefundLineInputDto {
  @IsInt()
  @Min(1)
  @Max(500)
  lineNo!: number;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;

  @Cents() amountCents!: number;
  @Cents() baseCents!: number;
  @Cents() iepsCents!: number;
  @Cents() ivaCents!: number;

  @IsBoolean()
  restock!: boolean;
}

/** `SaleRefundedPayload`; the record id is the refund id. */
export class SaleRefundedPayloadDto {
  @IsUUID()
  saleId!: string;

  @IsUUID()
  shiftId!: string;

  @IsIn(['REFUND', 'VOID'])
  kind!: 'REFUND' | 'VOID';

  @IsIn(REFUND_REASONS)
  reason!: (typeof REFUND_REASONS)[number];

  @IsOptional()
  @IsString()
  @MaxLength(120)
  note?: string | null;

  @IsUUID()
  staffId!: string;

  @IsOptional()
  @IsUUID()
  approverStaffId?: string | null;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(500)
  @ValidateNested({ each: true })
  @Type(() => RefundLineInputDto)
  lines!: RefundLineInputDto[];

  @Cents() totalCents!: number;
}
