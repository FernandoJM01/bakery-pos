import { IsNotEmpty, IsString, Matches, MaxLength } from 'class-validator';

export class ActivateDeviceDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^[A-HJ-NP-Z2-9]{8}$/, {
    message:
      'enrollmentCode must be an 8-character code from A-H, J-N, P-Z, 2-9',
  })
  enrollmentCode!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(40)
  appVersion!: string;
}
