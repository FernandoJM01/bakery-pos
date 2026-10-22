import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  Req,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Device } from '@prisma/client';
import { Public } from '../common/decorators/public.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { CurrentDevice } from './decorators/current-device.decorator';
import { RequireDevice } from './decorators/require-device.decorator';
import { DevicesService } from './devices.service';
import { ActivateDeviceDto } from './dto/activate-device.dto';
import { CreateDeviceDto } from './dto/create-device.dto';
import { ListDevicesQueryDto } from './dto/list-devices-query.dto';

interface RequestWithUser {
  user: {
    sub: string;
    sid: string;
    branchIds: string[];
    did?: string;
  };
}

@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get()
  @RequirePermission('devices.manage')
  async listDevices(@Query() query: ListDevicesQueryDto) {
    return this.devicesService.listDevices(query.branchId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission('devices.manage')
  async createDevice(
    @Body() dto: CreateDeviceDto,
    @Req() req: RequestWithUser,
  ) {
    return this.devicesService.createDevice(dto, req.user.sub);
  }

  @Post('activate')
  @Public()
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  async activateDevice(@Body() dto: ActivateDeviceDto) {
    return this.devicesService.activateDevice(dto);
  }

  @Get('me/staff')
  @Public()
  @RequireDevice()
  async getDeviceStaffBundle(@CurrentDevice() device: Device) {
    return this.devicesService.getStaffBundle(device);
  }

  @Post(':deviceId/enrollment-code')
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission('devices.manage')
  async regenerateEnrollmentCode(
    @Param('deviceId', ParseUUIDPipe) deviceId: string,
  ) {
    return this.devicesService.regenerateEnrollmentCode(deviceId);
  }

  @Post(':deviceId/revoke')
  @HttpCode(HttpStatus.OK)
  @RequirePermission('devices.manage')
  async revokeDevice(
    @Param('deviceId', ParseUUIDPipe) deviceId: string,
    @Req() req: RequestWithUser,
  ) {
    return this.devicesService.revokeDevice(deviceId, req.user.sub);
  }
}
