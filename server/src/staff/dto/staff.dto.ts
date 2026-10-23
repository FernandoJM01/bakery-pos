import { Role } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';

export class CreateStaffDto {
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  fullName!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(30)
  displayName!: string;

  @IsEnum(Role)
  role!: Role;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @MinLength(10)
  password?: string;

  @IsArray()
  @ArrayMinSize(1)
  @IsUUID('all', { each: true })
  branchIds!: string[];

  @Matches(/^[0-9]{4,6}$/, { message: 'PIN must be 4 to 6 digits' })
  pin!: string;
}

export class UpdateStaffDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  fullName?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(30)
  displayName?: string;

  @IsOptional()
  @IsEnum(Role)
  role?: Role;

  @IsOptional()
  @ValidateIf((_obj, val) => val !== null)
  @IsEmail()
  email?: string | null;

  @IsOptional()
  @IsString()
  @MinLength(10)
  password?: string;

  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @IsUUID('all', { each: true })
  branchIds?: string[];

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class SetPinDto {
  @Matches(/^[0-9]{4,6}$/, { message: 'PIN must be 4 to 6 digits' })
  pin!: string;
}

export class ListStaffQueryDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsEnum(Role)
  role?: Role;

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  includeInactive?: boolean;
}
