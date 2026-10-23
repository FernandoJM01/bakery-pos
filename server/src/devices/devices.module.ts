import { Module } from '@nestjs/common';
import { AuditModule } from '../audit/audit.module';
import { DevicesController } from './devices.controller';
import { DevicesService } from './devices.service';
import { DeviceGuard } from './guards/device.guard';

@Module({
  imports: [AuditModule],
  controllers: [DevicesController],
  providers: [DevicesService, DeviceGuard],
  exports: [DevicesService, DeviceGuard],
})
export class DevicesModule {}
