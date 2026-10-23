import { IsOptional, IsUUID } from 'class-validator';

export class ListDevicesQueryDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}
