import {
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
} from 'class-validator';
import { PERMISSION_KEYS } from '../../common/permissions';
import type { PermissionKey } from '../../common/permissions';

export class ApprovalDto {
  @IsUUID('all', { message: 'approverStaffId must be a valid UUID' })
  approverStaffId!: string;

  @IsString()
  @Matches(/^[0-9]{4,6}$/, { message: 'PIN must be between 4 and 6 digits' })
  pin!: string;

  @IsIn(PERMISSION_KEYS, { message: 'action must be a valid permission key' })
  action!: PermissionKey;

  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'reference must not exceed 100 characters' })
  reference?: string;
}
