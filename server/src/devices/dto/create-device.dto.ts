import {
  IsEnum,
  IsNotEmpty,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';
import { DeviceType } from '@prisma/client';

export class CreateDeviceDto {
  @IsUUID()
  @IsNotEmpty()
  branchId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(40)
  name!: string;

  @IsEnum(DeviceType)
  @IsNotEmpty()
  type!: DeviceType;
}
