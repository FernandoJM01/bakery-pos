import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

const MAX_CENTS = 100_000_000;

export const DENOMINATIONS = [
  100000, 50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50,
] as const;

export const MOVEMENT_REASONS = [
  'CHANGE_FUND',
  'SUPPLIER_PAYMENT',
  'BANK_DROP',
  'OTHER',
] as const;

/** `CashCountRow` */
export class CashCountRowDto {
  @IsIn(DENOMINATIONS)
  denominationCents!: number;

  @IsInt()
  @Min(0)
  @Max(100000)
  quantity!: number;
}

function Count() {
  return (target: object, key: string) => {
    IsArray()(target, key);
    ArrayMinSize(1)(target, key);
    ArrayMaxSize(DENOMINATIONS.length)(target, key);
    ValidateNested({ each: true })(target, key);
    Type(() => CashCountRowDto)(target, key);
  };
}

/** `ShiftOpenedPayload`; the record id is the shift id. */
export class ShiftOpenedPayloadDto {
  @IsUUID()
  staffId!: string;

  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  floatCents!: number;

  @Count()
  count!: CashCountRowDto[];
}

/** `CashMovementPayload`; the record id is the movement id. */
export class CashMovementPayloadDto {
  @IsUUID()
  shiftId!: string;

  @IsIn(['IN', 'OUT'])
  kind!: 'IN' | 'OUT';

  @IsInt()
  @Min(1)
  @Max(MAX_CENTS)
  amountCents!: number;

  @IsIn(MOVEMENT_REASONS)
  reason!: (typeof MOVEMENT_REASONS)[number];

  @IsOptional()
  @IsString()
  @MaxLength(120)
  note?: string | null;

  @IsUUID()
  staffId!: string;

  @IsOptional()
  @IsUUID()
  approverStaffId?: string | null;
}

/** `ShiftClosedPayload` */
export class ShiftClosedPayloadDto {
  @IsUUID()
  shiftId!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  zNumber!: number;

  @IsUUID()
  staffId!: string;

  @Count()
  count!: CashCountRowDto[];

  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  countedCents!: number;

  @IsInt()
  expectedCents!: number;

  @IsInt()
  varianceCents!: number;

  @IsBoolean()
  flagged!: boolean;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string | null;
}
