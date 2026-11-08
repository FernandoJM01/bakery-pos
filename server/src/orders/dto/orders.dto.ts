import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateIf,
  ValidateNested,
} from 'class-validator';

export const LOCAL_DATE = /^\d{4}-\d{2}-\d{2}$/;
export const PICKUP_TIME = /^([01]\d|2[0-3]):[0-5]\d$/;
const OrNull = () => ValidateIf((_o, v) => v !== null && v !== undefined);

export class CustomersQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(60)
  q?: string;
}

export class CustomerDto {
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  name!: string;

  @OrNull()
  @Matches(/^[0-9+ ]{7,20}$/)
  phone?: string | null;

  @OrNull()
  @Matches(/^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/)
  rfc?: string | null;

  @OrNull()
  @IsString()
  @MaxLength(500)
  notes?: string | null;
}

export class CustomerUpdateDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  name?: string;

  @OrNull()
  @Matches(/^[0-9+ ]{7,20}$/)
  phone?: string | null;

  @OrNull()
  @Matches(/^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/)
  rfc?: string | null;

  @OrNull()
  @IsString()
  @MaxLength(500)
  notes?: string | null;

  @IsOptional()
  isActive?: boolean;
}

export class OrderLineDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;
}

class OrderFieldsDto {
  @IsInt()
  @Min(0)
  @Max(127)
  weekdays!: number;

  @Matches(LOCAL_DATE)
  startDate!: string;

  @OrNull()
  @Matches(LOCAL_DATE)
  endDate?: string | null;

  @Matches(PICKUP_TIME)
  pickupTime!: string;

  @IsIn(['CHARGE', 'NO_CHARGE'])
  missedRule!: 'CHARGE' | 'NO_CHARGE';

  @OrNull()
  @IsString()
  @MaxLength(500)
  note?: string | null;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => OrderLineDto)
  lines!: OrderLineDto[];
}

export class OrderCreateDto extends OrderFieldsDto {
  @IsUUID()
  customerId!: string;

  @IsUUID()
  branchId!: string;

  @IsIn(['STANDING', 'ONE_OFF'])
  kind!: 'STANDING' | 'ONE_OFF';
}

export class OrderUpdateDto extends OrderFieldsDto {}

export class OrderPauseDto {
  @Matches(LOCAL_DATE)
  from!: string;

  @OrNull()
  @Matches(LOCAL_DATE)
  until?: string | null;
}

export class OrderSkipDto {
  @Matches(LOCAL_DATE)
  date!: string;
}

export class OrdersQueryDto {
  @IsOptional()
  @IsUUID()
  customerId?: string;

  @IsOptional()
  @IsUUID()
  branchId?: string;
}

export class PickListQueryDto {
  @IsUUID()
  branchId!: string;

  @Matches(LOCAL_DATE)
  date!: string;
}

/** `OrderPrepaidPayload`; the record id is the prepaid entry id. */
export class OrderPrepaidPayloadDto {
  @IsUUID()
  customerId!: string;

  @IsUUID()
  shiftId!: string;

  @IsInt()
  @Min(1)
  @Max(100_000_000)
  amountCents!: number;

  @IsUUID()
  staffId!: string;
}
