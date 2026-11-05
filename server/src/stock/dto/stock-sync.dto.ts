import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsInt,
  IsOptional,
  IsUUID,
  Matches,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

export const WASTE_REASONS = ['BURNT', 'EXPIRED', 'DAMAGED', 'UNSOLD'] as const;
export const LOCAL_DATE = /^\d{4}-\d{2}-\d{2}$/;

/** `StockProducedPayload`; the record id is the lot id. */
export class StockProducedPayloadDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;

  @Matches(LOCAL_DATE)
  producedOn!: string;

  @IsUUID()
  staffId!: string;
}

/** `StockWastedPayload` */
export class StockWastedPayloadDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;

  @IsIn(WASTE_REASONS)
  reason!: (typeof WASTE_REASONS)[number];

  @IsOptional()
  @IsUUID()
  lotId?: string | null;

  @IsUUID()
  staffId!: string;
}

export class StockCountLineDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(0)
  @Max(999999)
  counted!: number;
}

/** `StockCountedPayload` */
export class StockCountedPayloadDto {
  @IsUUID()
  staffId!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(500)
  @ValidateNested({ each: true })
  @Type(() => StockCountLineDto)
  lines!: StockCountLineDto[];
}
