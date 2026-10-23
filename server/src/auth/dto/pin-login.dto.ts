import { IsString, IsUUID, Matches } from 'class-validator';

export class PinLoginDto {
  @IsUUID('all', { message: 'staffId must be a valid UUID' })
  staffId!: string;

  @IsString()
  @Matches(/^[0-9]{4,6}$/, { message: 'PIN must be between 4 and 6 digits' })
  pin!: string;
}
