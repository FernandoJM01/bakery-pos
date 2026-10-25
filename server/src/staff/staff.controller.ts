import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import {
  CreateStaffDto,
  ListStaffQueryDto,
  SetPinDto,
  UpdateStaffDto,
} from './dto/staff.dto';
import { StaffService } from './staff.service';

@Controller('staff')
export class StaffController {
  constructor(private readonly staffService: StaffService) {}

  @Get()
  @RequirePermission('staff.manage')
  async list(@Query() query: ListStaffQueryDto) {
    return this.staffService.list(query);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission('staff.manage')
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateStaffDto,
  ) {
    return this.staffService.create(user, dto);
  }

  @Get(':staffId')
  @RequirePermission('staff.manage')
  async get(@Param('staffId', ParseUUIDPipe) staffId: string) {
    return this.staffService.get(staffId);
  }

  @Patch(':staffId')
  @RequirePermission('staff.manage')
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('staffId', ParseUUIDPipe) staffId: string,
    @Body() dto: UpdateStaffDto,
  ) {
    return this.staffService.update(user, staffId, dto);
  }

  @Put(':staffId/pin')
  @HttpCode(HttpStatus.NO_CONTENT)
  @RequirePermission('staff.manage')
  async setPin(
    @CurrentUser() user: AuthenticatedUser,
    @Param('staffId', ParseUUIDPipe) staffId: string,
    @Body() dto: SetPinDto,
  ) {
    return this.staffService.setPin(user, staffId, dto);
  }
}
