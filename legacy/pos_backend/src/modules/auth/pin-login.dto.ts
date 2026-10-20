import { IsNotEmpty, IsString, Length } from 'class-validator';

export class PinLoginDto {
  @IsNotEmpty()
  @IsString()
  username: string;

  @IsNotEmpty()
  @IsString()
  @Length(4, 6)
  pin: string;
}
