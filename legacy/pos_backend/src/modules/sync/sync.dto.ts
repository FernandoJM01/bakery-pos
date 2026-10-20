import { IsNotEmpty, IsString, IsEnum, IsInt, IsOptional, ValidateNested, IsArray } from 'class-validator';
import { Type } from 'class-transformer';
import { LedgerEventType } from '../../common/types';

export class LedgerEventDto {
  @IsNotEmpty()
  @IsString()
  client_event_id: string;

  @IsNotEmpty()
  @IsString()
  branch_id: string;

  @IsNotEmpty()
  @IsString()
  terminal_id: string;

  @IsNotEmpty()
  @IsEnum(LedgerEventType)
  event_type: LedgerEventType;

  @IsNotEmpty()
  @IsString()
  user_id: string;

  @IsNotEmpty()
  @IsString()
  product_id: string;

  @IsNotEmpty()
  @IsInt()
  quantity_change: number;

  @IsOptional()
  @IsString()
  batch_number?: string;

  @IsOptional()
  @IsString()
  reference_id?: string;

  @IsOptional()
  metadata?: any;

  @IsNotEmpty()
  client_timestamp: string; // ISO string
}

export class BatchSyncPushDto {
  @IsNotEmpty()
  @IsString()
  branch_id: string;

  @IsNotEmpty()
  @IsString()
  terminal_id: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LedgerEventDto)
  events: LedgerEventDto[];
}
