import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { LOCAL_DATE, WASTE_REASONS } from './stock-sync.dto';

class PageDto {
  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(200)
  limit?: number;
}

export class StockLevelsQueryDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}

export class StockEventsQueryDto extends PageDto {
  @IsUUID()
  branchId!: string;

  @IsUUID()
  variantId!: string;
}

export class WasteQueryDto extends PageDto {
  @IsOptional()
  @IsISO8601({ strict: true })
  from?: string;

  @IsOptional()
  @IsISO8601({ strict: true })
  to?: string;

  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsIn(WASTE_REASONS)
  reason?: (typeof WASTE_REASONS)[number];
}

export class TransfersQueryDto extends PageDto {
  @IsOptional()
  @IsIn(['SENT', 'RECEIVED'])
  status?: 'SENT' | 'RECEIVED';
}

class TransferLineDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(9999)
  quantity!: number;
}

export class CreateTransferDto {
  @IsUUID()
  fromBranchId!: string;

  @IsUUID()
  toBranchId!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(200)
  @ValidateNested({ each: true })
  @Type(() => TransferLineDto)
  lines!: TransferLineDto[];
}

class ReceiveLineDto {
  @IsUUID()
  variantId!: string;

  @Matches(LOCAL_DATE)
  producedOn!: string;

  @IsInt()
  @Min(0)
  @Max(9999)
  quantityReceived!: number;
}

export class ReceiveTransferDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(200)
  @ValidateNested({ each: true })
  @Type(() => ReceiveLineDto)
  lines!: ReceiveLineDto[];
}
