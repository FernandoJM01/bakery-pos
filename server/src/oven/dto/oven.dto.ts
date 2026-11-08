import {
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
  ValidateIf,
} from 'class-validator';

const MAX_CENTS = 10_000_000;
const OrNull = () => ValidateIf((_o, v) => v !== null && v !== undefined);

export class OvenFeeRuleCreateDto {
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  name!: string;

  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  baseCents!: number;

  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  perKgCents!: number;

  @IsUUID()
  ivaRateId!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(10000)
  sortOrder?: number;
}

export class OvenFeeRuleUpdateDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  name?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  baseCents?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  perKgCents?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(10000)
  sortOrder?: number;
}

export class OvenBranchDto {
  @IsBoolean()
  enabled!: boolean;
}

export class OvenTicketsQueryDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @Matches(/^\d{4}-\d{2}-\d{2}$/)
  from!: string;

  @Matches(/^\d{4}-\d{2}-\d{2}$/)
  to!: string;
}

/** `OvenReceivedPayload`; the record id is the oven ticket id. */
export class OvenReceivedPayloadDto {
  @IsString()
  @MinLength(1)
  @MaxLength(10)
  tag!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  customerName!: string;

  @OrNull()
  @Matches(/^[0-9+ ]{7,20}$/)
  phone?: string | null;

  @IsString()
  @MinLength(1)
  @MaxLength(200)
  description!: string;

  @IsUUID()
  ruleId!: string;

  @IsInt()
  @Min(1)
  @Max(100_000)
  weightGrams!: number;

  @IsInt()
  @Min(0)
  @Max(MAX_CENTS)
  feeCents!: number;

  @IsISO8601({ strict: true })
  requestedAt!: string;

  @IsUUID()
  staffId!: string;

  /** The fee sale, when paid at drop-off. */
  @OrNull()
  @IsUUID()
  feeSaleId?: string | null;
}

/** `OvenStatusPayload` */
export class OvenStatusPayloadDto {
  @IsUUID()
  ticketId!: string;

  @IsIn(['IN_OVEN', 'READY'])
  status!: 'IN_OVEN' | 'READY';

  @IsUUID()
  staffId!: string;
}

/** `OvenPickedUpPayload` */
export class OvenPickedUpPayloadDto {
  @IsUUID()
  ticketId!: string;

  @IsUUID()
  staffId!: string;

  /** The fee sale, when paid at pickup. */
  @OrNull()
  @IsUUID()
  feeSaleId?: string | null;
}
