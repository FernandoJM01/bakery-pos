import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsInt,
  IsISO8601,
  IsObject,
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

export class CatalogPullQueryDto {
  // A bigint on the wire; kept as a string until the service parses it.
  @Matches(/^\d{1,18}$/, { message: 'since must be a whole number ≥ 0' })
  since!: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(1000)
  limit?: number;
}

export class SyncRecordDto {
  @IsUUID()
  id!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(60)
  type!: string;

  @IsISO8601({ strict: true })
  occurredAt!: string;

  @IsOptional()
  @IsUUID()
  actorStaffId?: string | null;

  @IsObject()
  payload!: Record<string, unknown>;
}

export class SyncPushDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => SyncRecordDto)
  records!: SyncRecordDto[];
}

export const OFFLINE_AUDIT_ACTIONS = [
  'auth.login_success',
  'auth.login_failure',
  'auth.locked',
  'auth.approval_granted',
  'sale.ticket_discarded',
] as const;

/** What a discarded ticket held (`sale.ticket_discarded`, M3 brief 4.1). */
export class DiscardedTicketDto {
  @IsInt()
  @Min(1)
  @Max(500)
  lineCount!: number;

  @IsInt()
  @Min(0)
  @Max(100_000_000)
  amountCents!: number;
}

/** `OfflineAuditPayload`; checked per record, so a bad one is quarantined. */
export class OfflineAuditPayloadDto {
  @IsIn(OFFLINE_AUDIT_ACTIONS)
  action!: (typeof OFFLINE_AUDIT_ACTIONS)[number];

  @IsUUID()
  staffId!: string;

  @ValidateIf(
    (o: OfflineAuditPayloadDto) =>
      o.action === 'auth.approval_granted' || o.approverStaffId != null,
  )
  @IsUUID()
  approverStaffId?: string | null;

  @ValidateIf(
    (o: OfflineAuditPayloadDto) =>
      o.action === 'auth.approval_granted' || o.approvalAction != null,
  )
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  approvalAction?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  reference?: string | null;

  @ValidateIf(
    (o: OfflineAuditPayloadDto) =>
      o.action === 'sale.ticket_discarded' || o.ticket != null,
  )
  @IsObject()
  @ValidateNested()
  @Type(() => DiscardedTicketDto)
  ticket?: DiscardedTicketDto | null;
}

export class QuarantineQueryDto {
  @IsOptional()
  @IsIn(['OPEN', 'RESOLVED', 'ALL'])
  status?: 'OPEN' | 'RESOLVED' | 'ALL';

  @IsOptional()
  @IsUUID()
  deviceId?: string;

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

export class QuarantineResolveDto {
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  note!: string;
}
